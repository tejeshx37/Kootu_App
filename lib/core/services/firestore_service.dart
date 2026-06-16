import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/list_item.dart';
import '../models/offer.dart';
import '../models/room.dart';

/// Typed Firestore wrappers. Widgets never touch FirebaseFirestore directly —
/// they consume Riverpod providers that route through this service.
class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  // Users
  /// Creates `users/{uid}` and seeds a default Family Room with the same set
  /// of items that ship in MockData['1']. Idempotent: if the user doc already
  /// exists we do nothing.
  Future<String?> bootstrapNewUser({
    required String uid,
    required String phone,
    required List<ListItem> seedItems,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final existing = await userRef.get();
    if (existing.exists) return null;

    final roomRef = _db.collection('rooms').doc();
    final now = DateTime.now();
    final inviteCode = await _reserveInviteCode(roomRef.id, uid);
    final batch = _db.batch();

    batch.set(roomRef, {
      'name': 'Family Room',
      'emoji': '🏠',
      'createdBy': uid,
      'memberIds': [uid],
      'memberAvatars': const ['👤'],
      'createdAt': Timestamp.fromDate(now),
      'itemCount': seedItems.length,
      'neededCount': seedItems.where((i) => !i.bought).length,
      'inviteCode': inviteCode,
    });

    for (final item in seedItems) {
      final itemRef = roomRef.collection('items').doc();
      final map = item.toMap();
      map['addedBy'] = uid;
      batch.set(itemRef, map);
    }

    batch.set(userRef, AppUser(
      id: uid,
      name: 'Friend',
      phone: phone,
      locality: 'Chennai',
      city: 'Chennai',
      memberSince: now,
      activeRoomIds: [roomRef.id],
    ).toMap());

    await batch.commit();
    return roomRef.id;
  }

  Future<AppUser?> getUser(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.id, snap.data()!);
  }

  Future<void> upsertUser(AppUser user) =>
      _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));

  // Rooms
  Stream<List<Room>> watchRoomsForUser(String userId) => _db
      .collection('rooms')
      .where('memberIds', arrayContains: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => Room.fromMap(d.id, d.data())).toList());

  Stream<Room?> watchRoom(String roomId) => _db
      .collection('rooms')
      .doc(roomId)
      .snapshots()
      .map((d) => d.exists ? Room.fromMap(d.id, d.data()!) : null);

  /// Creates a new room with the user as creator and only member.
  /// Generates a unique 6-char invite code and writes the corresponding
  /// `invites/{code}` lookup doc.
  Future<Room> createRoom({
    required String uid,
    required String name,
    required String emoji,
  }) async {
    final roomRef = _db.collection('rooms').doc();
    final now = DateTime.now();
    final inviteCode = await _reserveInviteCode(roomRef.id, uid);

    await roomRef.set({
      'name': name,
      'emoji': emoji,
      'createdBy': uid,
      'memberIds': [uid],
      'memberAvatars': const ['👤'],
      'createdAt': Timestamp.fromDate(now),
      'itemCount': 0,
      'neededCount': 0,
      'inviteCode': inviteCode,
    });

    return Room(
      id: roomRef.id,
      name: name,
      emoji: emoji,
      createdBy: uid,
      memberIds: [uid],
      memberAvatars: const ['👤'],
      createdAt: now,
      inviteCode: inviteCode,
    );
  }

  /// Looks up an invite code, returns the joined Room on success, or `null`
  /// if the code does not exist. Throws if Firestore denies the update.
  Future<Room?> joinRoomByInviteCode(String code, String uid) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) return null;
    final invite = await _db.collection('invites').doc(normalized).get();
    if (!invite.exists) return null;
    final roomId = invite.data()?['roomId'] as String?;
    if (roomId == null) return null;

    await _db.collection('rooms').doc(roomId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });

    final snap = await _db.collection('rooms').doc(roomId).get();
    if (!snap.exists) return null;
    return Room.fromMap(snap.id, snap.data()!);
  }

  /// Removes the user from a room. Refuses if the user is the creator
  /// (they must delete the room instead).
  Future<void> leaveRoom(String roomId, String uid) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final snap = await roomRef.get();
    if (!snap.exists) return;
    if (snap.data()?['createdBy'] == uid) {
      throw StateError('Creator cannot leave their own room — delete it instead.');
    }
    await roomRef.update({
      'memberIds': FieldValue.arrayRemove([uid]),
    });
  }

  /// Deletes a room and all its items + the matching invite doc.
  /// Only the creator may delete.
  Future<void> deleteRoom(String roomId, String uid) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    final snap = await roomRef.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    if (data['createdBy'] != uid) {
      throw StateError('Only the room creator can delete this room.');
    }

    final items = await roomRef.collection('items').get();
    final batch = _db.batch();
    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }
    final inviteCode = data['inviteCode'] as String?;
    if (inviteCode != null) {
      batch.delete(_db.collection('invites').doc(inviteCode));
    }
    batch.delete(roomRef);
    await batch.commit();
  }

  /// Picks a fresh 6-char code, retrying up to 5 times on collision, and
  /// writes the invite lookup doc inside a transaction so the read+write
  /// is atomic. Returns the code on success.
  Future<String> _reserveInviteCode(String roomId, String uid) async {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = List.generate(
              6, (_) => alphabet[rng.nextInt(alphabet.length)])
          .join();
      final ref = _db.collection('invites').doc(code);
      try {
        await _db.runTransaction((tx) async {
          final snap = await tx.get(ref);
          if (snap.exists) {
            throw _CodeCollision();
          }
          tx.set(ref, {
            'roomId': roomId,
            'createdBy': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
        return code;
      } on _CodeCollision {
        continue;
      }
    }
    throw StateError('Could not generate a unique invite code.');
  }

  // Items
  Stream<List<ListItem>> watchItems(String roomId) => _db
      .collection('rooms')
      .doc(roomId)
      .collection('items')
      .orderBy('addedAt', descending: true)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => ListItem.fromMap(d.id, d.data())).toList());

  Future<void> addItem(String roomId, ListItem item) => _db
      .collection('rooms')
      .doc(roomId)
      .collection('items')
      .add(item.toMap());

  Future<void> toggleItemBought({
    required String roomId,
    required ListItem item,
    required String boughtByUserId,
  }) {
    final next = !item.bought;
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('items')
        .doc(item.id)
        .update({
      'bought': next,
      'boughtAt': next ? Timestamp.now() : null,
      'boughtBy': next ? boughtByUserId : null,
    });
  }

  // Offers
  Stream<List<Offer>> watchActiveOffers() => _db
      .collection('offers')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Offer.fromMap(d.id, d.data())).toList());
}

class _CodeCollision implements Exception {}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/list_item.dart';
import '../models/offer.dart';
import '../models/room.dart';
import '../models/service_models.dart';

/// Typed Firestore wrappers. Widgets never touch FirebaseFirestore directly —
/// they consume Riverpod providers that route through this service.
class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  // Users
  /// Creates `users/{uid}` for a brand-new account. Idempotent: if the user
  /// doc already exists we do nothing. New accounts start with zero rooms —
  /// the user creates or joins one explicitly from Home. The display name is
  /// captured separately on the set-name screen, so it may be empty here
  /// (Google sign-in can pre-fill it).
  Future<void> bootstrapNewUser({
    required String uid,
    required String phone,
    String name = '',
    String? email,
    String? photoUrl,
    String locality = '',
    String city = '',
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final existing = await userRef.get();
    if (existing.exists) return;

    await userRef.set(AppUser(
      id: uid,
      name: name,
      phone: phone,
      email: email,
      photoUrl: photoUrl,
      locality: locality,
      city: city,
      memberSince: DateTime.now(),
      activeRoomIds: const [],
    ).toMap());
  }

  Future<AppUser?> getUser(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.id, snap.data()!);
  }

  Stream<AppUser?> watchUser(String userId) => _db
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((d) => d.exists ? AppUser.fromMap(d.id, d.data()!) : null);

  Future<void> upsertUser(AppUser user) =>
      _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));

  /// Updates only the provided profile fields on `users/{uid}`.
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? locality,
    String? city,
  }) {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (locality != null) 'locality': locality,
      if (city != null) 'city': city,
    };
    return _db.collection('users').doc(uid).set(
          updates,
          SetOptions(merge: true),
        );
  }

  /// Sets (or clears, when [nickname] is empty) the private nickname this user
  /// has given to another member, stored on their own user doc.
  Future<void> setNickname({
    required String uid,
    required String contactUid,
    required String nickname,
  }) {
    final trimmed = nickname.trim();
    return _db.collection('users').doc(uid).update({
      'nicknames.$contactUid':
          trimmed.isEmpty ? FieldValue.delete() : trimmed,
    });
  }

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
    String creatorName = '',
    String creatorAvatar = '👤',
  }) async {
    final roomRef = _db.collection('rooms').doc();
    final now = DateTime.now();
    final inviteCode = await _reserveInviteCode(roomRef.id, uid);
    final creator = RoomMember(
      uid: uid,
      name: creatorName,
      avatar: creatorAvatar,
    );

    await roomRef.set({
      'name': name,
      'emoji': emoji,
      'createdBy': uid,
      'memberIds': [uid],
      'memberAvatars': [creatorAvatar],
      'members': {uid: creator.toMap()},
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
      memberAvatars: [creatorAvatar],
      members: {uid: creator},
      createdAt: now,
      inviteCode: inviteCode,
    );
  }

  /// Looks up an invite code, returns the joined Room on success, or `null`
  /// if the code does not exist. Throws if Firestore denies the update.
  Future<Room?> joinRoomByInviteCode(
    String code,
    String uid, {
    String name = '',
    String avatar = '👤',
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) return null;
    final invite = await _db.collection('invites').doc(normalized).get();
    if (!invite.exists) return null;
    final roomId = invite.data()?['roomId'] as String?;
    if (roomId == null) return null;

    await _db.collection('rooms').doc(roomId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
      'memberAvatars': FieldValue.arrayUnion([avatar]),
      'members.$uid': RoomMember(uid: uid, name: name, avatar: avatar).toMap(),
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

  /// Adds an item and returns the new document id.
  Future<String> addItem(String roomId, ListItem item) async {
    final ref = await _db
        .collection('rooms')
        .doc(roomId)
        .collection('items')
        .add(item.toMap());
    return ref.id;
  }

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

  /// Updates editable fields on a single item (name, category, quantity, note).
  /// Only the provided fields are written.
  Future<void> updateItem({
    required String roomId,
    required String itemId,
    String? name,
    String? categoryId,
    String? quantity,
    String? note,
  }) {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (categoryId != null) 'category': categoryId,
      if (quantity != null) 'quantity': quantity,
      if (note != null) 'note': note,
    };
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('items')
        .doc(itemId)
        .update(updates);
  }

  Future<void> deleteItem(String roomId, String itemId) => _db
      .collection('rooms')
      .doc(roomId)
      .collection('items')
      .doc(itemId)
      .delete();

  // Offers
  Stream<List<Offer>> watchActiveOffers() => _db
      .collection('offers')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Offer.fromMap(d.id, d.data())).toList());

  // Services catalogue
  Stream<List<ServiceCategory>> watchServiceCategories() => _db
      .collection('serviceCategories')
      .orderBy('order')
      .snapshots()
      .map((s) =>
          s.docs.map((d) => ServiceCategory.fromMap(d.data())).toList());

  Stream<List<ServiceProvider>> watchServiceProviders() => _db
      .collection('serviceProviders')
      .orderBy('rating', descending: true)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => ServiceProvider.fromMap(d.id, d.data())).toList());
}

class _CodeCollision implements Exception {}

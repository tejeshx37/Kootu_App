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

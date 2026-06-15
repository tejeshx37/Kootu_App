import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/list_item.dart';
import '../models/offer.dart';
import '../models/room.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

/// Rooms for the current user. Falls back to mock rooms when no rooms are
/// returned (unauthenticated or empty backend), so dev screens render.
final roomsProvider = StreamProvider<List<Room>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield MockData.rooms;
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  await for (final rooms in svc.watchRoomsForUser(user.uid)) {
    yield rooms.isEmpty ? MockData.rooms : rooms;
  }
});

/// Holds the currently active room id for the home/offers screens.
final selectedRoomIdProvider = StateProvider<String>((ref) {
  final rooms = ref.watch(roomsProvider).asData?.value ?? MockData.rooms;
  return rooms.isNotEmpty ? rooms.first.id : '1';
});

final selectedRoomProvider = Provider<Room?>((ref) {
  final id = ref.watch(selectedRoomIdProvider);
  final rooms = ref.watch(roomsProvider).asData?.value ?? MockData.rooms;
  for (final r in rooms) {
    if (r.id == id) return r;
  }
  return rooms.isNotEmpty ? rooms.first : null;
});

final itemsProvider =
    StreamProvider.family<List<ListItem>, String>((ref, roomId) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield MockData.itemsByRoom[roomId] ?? const [];
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  await for (final items in svc.watchItems(roomId)) {
    yield items.isEmpty
        ? (MockData.itemsByRoom[roomId] ?? const [])
        : items;
  }
});

final offersProvider = StreamProvider<List<Offer>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield MockData.offers;
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  await for (final offers in svc.watchActiveOffers()) {
    yield offers.isEmpty ? MockData.offers : offers;
  }
});

/// "Matched only" filter for OffersScreen.
final matchedOnlyProvider = StateProvider<bool>((_) => false);

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

/// Rooms for the current user. Signed-out (dev mode) sees the mock rooms so
/// every screen still renders; signed-in users see the real Firestore stream
/// — an empty list stays empty so the "create your first room" UX shows.
final roomsProvider = StreamProvider<List<Room>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield MockData.rooms;
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  yield* svc.watchRoomsForUser(user.uid);
});

/// Holds the currently active room id for the home/offers screens. Falls back
/// to the first available room whenever the current selection isn't present
/// in the live room list (e.g. after sign-in the seeded room has a new id).
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
  yield* svc.watchItems(roomId);
});

/// Offers are global; we keep the mock fallback even for signed-in users
/// because no real offers exist yet and the empty state would look broken.
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

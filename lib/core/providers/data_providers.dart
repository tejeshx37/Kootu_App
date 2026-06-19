import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/list_item.dart';
import '../models/offer.dart';
import '../models/room.dart';
import '../models/service_models.dart';
import '../services/ai_categorizer.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

final aiCategorizerProvider = Provider<AiCategorizer>((ref) {
  return AiCategorizer();
});

/// Rooms for the current user, straight from Firestore. Signed-out yields an
/// empty list so the "create your first room" UX shows.
final roomsProvider = StreamProvider<List<Room>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield const [];
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  yield* svc.watchRoomsForUser(user.uid);
});

/// The user's explicit room choice (set by the room switcher / create / join
/// flows). Null means "no explicit pick yet", so we default to the first room.
final explicitRoomIdProvider = StateProvider<String?>((ref) => null);

/// The currently active room id for the home/offers screens. Reacts to rooms
/// loading after sign-in and falls back to the first available room whenever
/// the explicit selection isn't present in the live room list.
final selectedRoomIdProvider = Provider<String>((ref) {
  final explicit = ref.watch(explicitRoomIdProvider);
  final rooms = ref.watch(roomsProvider).asData?.value ?? const [];
  if (explicit != null && rooms.any((r) => r.id == explicit)) {
    return explicit;
  }
  return rooms.isNotEmpty ? rooms.first.id : '';
});

final selectedRoomProvider = Provider<Room?>((ref) {
  final id = ref.watch(selectedRoomIdProvider);
  final rooms = ref.watch(roomsProvider).asData?.value ?? const [];
  for (final r in rooms) {
    if (r.id == id) return r;
  }
  return rooms.isNotEmpty ? rooms.first : null;
});

final itemsProvider =
    StreamProvider.family<List<ListItem>, String>((ref, roomId) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null || roomId.isEmpty) {
    yield const [];
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  yield* svc.watchItems(roomId);
});

/// Active offers, global, straight from Firestore. Empty stays empty so the
/// offers screen shows its empty state instead of fake data.
final offersProvider = StreamProvider<List<Offer>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield const [];
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  yield* svc.watchActiveOffers();
});

/// The signed-in user's Firestore profile document, live.
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield null;
    return;
  }
  final svc = ref.watch(firestoreServiceProvider);
  yield* svc.watchUser(user.uid);
});

final serviceCategoriesProvider =
    StreamProvider<List<ServiceCategory>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(firestoreServiceProvider).watchServiceCategories();
});

final serviceProvidersProvider =
    StreamProvider<List<ServiceProvider>>((ref) async* {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(firestoreServiceProvider).watchServiceProviders();
});

/// "Matched only" filter for OffersScreen.
final matchedOnlyProvider = StateProvider<bool>((_) => false);

/// A person you share at least one room with — the real source for the
/// Contact Nicknames screen. Derived live from your rooms' denormalized
/// `members`, excluding yourself, deduped across rooms.
class Contact {
  final String uid;
  final String name;
  final String avatar;
  final List<String> roomNames;
  const Contact({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.roomNames,
  });
}

final contactsProvider = Provider<List<Contact>>((ref) {
  final selfUid = ref.watch(authStateProvider).asData?.value?.uid;
  final rooms = ref.watch(roomsProvider).asData?.value ?? const [];

  final byUid = <String, RoomMember>{};
  final roomsFor = <String, List<String>>{};
  for (final room in rooms) {
    for (final m in room.members.values) {
      if (m.uid == selfUid || m.uid.isEmpty) continue;
      byUid[m.uid] = m;
      roomsFor.putIfAbsent(m.uid, () => []).add(room.name);
    }
  }

  final contacts = byUid.values
      .map((m) => Contact(
            uid: m.uid,
            name: m.name.isEmpty ? 'Member' : m.name,
            avatar: m.avatar,
            roomNames: roomsFor[m.uid] ?? const [],
          ))
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return contacts;
});

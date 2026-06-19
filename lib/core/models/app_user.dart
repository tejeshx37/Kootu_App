import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String locality;
  final String city;
  final DateTime memberSince;
  final List<String> activeRoomIds;
  /// Private contact nicknames (other member's uid → nickname), only ever
  /// read/written by this user.
  final Map<String, String> nicknames;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    required this.locality,
    required this.city,
    required this.memberSince,
    required this.activeRoomIds,
    this.nicknames = const {},
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) => AppUser(
        id: id,
        name: (data['name'] ?? '') as String,
        phone: (data['phone'] ?? '') as String,
        email: data['email'] as String?,
        photoUrl: data['photoUrl'] as String?,
        locality: (data['locality'] ?? '') as String,
        city: (data['city'] ?? '') as String,
        memberSince: (data['memberSince'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        activeRoomIds:
            List<String>.from((data['activeRoomIds'] ?? const []) as List),
        nicknames: Map<String, String>.from(
            (data['nicknames'] ?? const <String, String>{}) as Map),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'photoUrl': photoUrl,
        'locality': locality,
        'city': city,
        'memberSince': Timestamp.fromDate(memberSince),
        'activeRoomIds': activeRoomIds,
        'nicknames': nicknames,
      };
}

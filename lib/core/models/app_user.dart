import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String locality;
  final String city;
  final DateTime memberSince;
  final List<String> activeRoomIds;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.locality,
    required this.city,
    required this.memberSince,
    required this.activeRoomIds,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) => AppUser(
        id: id,
        name: (data['name'] ?? '') as String,
        phone: (data['phone'] ?? '') as String,
        locality: (data['locality'] ?? '') as String,
        city: (data['city'] ?? '') as String,
        memberSince: (data['memberSince'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        activeRoomIds:
            List<String>.from((data['activeRoomIds'] ?? const []) as List),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'locality': locality,
        'city': city,
        'memberSince': Timestamp.fromDate(memberSince),
        'activeRoomIds': activeRoomIds,
      };
}

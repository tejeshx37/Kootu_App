import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String emoji;
  final String createdBy;
  final List<String> memberIds;
  final List<String> memberAvatars;
  /// Denormalized member profiles (uid → name/avatar) so co-members can show
  /// each other's display names without reading private `users/{uid}` docs.
  final Map<String, RoomMember> members;
  final DateTime createdAt;
  final int itemCount;
  final int neededCount;
  final RoomBudget? budget;
  final String? inviteCode;

  const Room({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdBy,
    required this.memberIds,
    required this.memberAvatars,
    this.members = const {},
    required this.createdAt,
    this.itemCount = 0,
    this.neededCount = 0,
    this.budget,
    this.inviteCode,
  });

  factory Room.fromMap(String id, Map<String, dynamic> data) => Room(
        id: id,
        name: (data['name'] ?? '') as String,
        emoji: (data['emoji'] ?? '🏠') as String,
        createdBy: (data['createdBy'] ?? '') as String,
        memberIds:
            List<String>.from((data['memberIds'] ?? const []) as List),
        memberAvatars: List<String>.from(
            (data['memberAvatars'] ?? const []) as List),
        members: ((data['members'] ?? const {}) as Map).map(
          (key, value) => MapEntry(
            key as String,
            RoomMember.fromMap(
                key, Map<String, dynamic>.from(value as Map)),
          ),
        ),
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        itemCount: (data['itemCount'] ?? 0) as int,
        neededCount: (data['neededCount'] ?? 0) as int,
        budget: data['budget'] == null
            ? null
            : RoomBudget.fromMap(
                Map<String, dynamic>.from(data['budget'] as Map)),
        inviteCode: data['inviteCode'] as String?,
      );
}

class RoomMember {
  final String uid;
  final String name;
  final String avatar;
  const RoomMember({
    required this.uid,
    required this.name,
    required this.avatar,
  });

  factory RoomMember.fromMap(String uid, Map<String, dynamic> m) => RoomMember(
        uid: uid,
        name: (m['name'] ?? '') as String,
        avatar: (m['avatar'] ?? '👤') as String,
      );

  Map<String, dynamic> toMap() => {'name': name, 'avatar': avatar};
}

class RoomBudget {
  final num spent;
  final num total;
  const RoomBudget({required this.spent, required this.total});
  factory RoomBudget.fromMap(Map<String, dynamic> m) =>
      RoomBudget(spent: m['spent'] as num, total: m['total'] as num);
  double get progress => total == 0 ? 0 : (spent / total).clamp(0, 1).toDouble();
}

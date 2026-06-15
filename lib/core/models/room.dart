import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String emoji;
  final String createdBy;
  final List<String> memberIds;
  final List<String> memberAvatars;
  final DateTime createdAt;
  final int itemCount;
  final int neededCount;
  final RoomBudget? budget;

  const Room({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdBy,
    required this.memberIds,
    required this.memberAvatars,
    required this.createdAt,
    this.itemCount = 0,
    this.neededCount = 0,
    this.budget,
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
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        itemCount: (data['itemCount'] ?? 0) as int,
        neededCount: (data['neededCount'] ?? 0) as int,
        budget: data['budget'] == null
            ? null
            : RoomBudget.fromMap(
                Map<String, dynamic>.from(data['budget'] as Map)),
      );
}

class RoomBudget {
  final num spent;
  final num total;
  const RoomBudget({required this.spent, required this.total});
  factory RoomBudget.fromMap(Map<String, dynamic> m) =>
      RoomBudget(spent: m['spent'] as num, total: m['total'] as num);
  double get progress => total == 0 ? 0 : (spent / total).clamp(0, 1).toDouble();
}

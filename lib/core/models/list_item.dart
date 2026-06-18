import 'package:cloud_firestore/cloud_firestore.dart';

class ListItem {
  final String id;
  final String name;
  final String categoryId;
  final String addedBy;
  final String addedByName;
  final DateTime addedAt;
  final bool bought;
  final DateTime? boughtAt;
  final String? boughtBy;
  final num? price;
  final String? quantity;
  final String? note;

  const ListItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.addedBy,
    required this.addedByName,
    required this.addedAt,
    required this.bought,
    this.boughtAt,
    this.boughtBy,
    this.price,
    this.quantity,
    this.note,
  });

  factory ListItem.fromMap(String id, Map<String, dynamic> data) => ListItem(
        id: id,
        name: (data['name'] ?? '') as String,
        categoryId: (data['category'] ?? 'other') as String,
        addedBy: (data['addedBy'] ?? '') as String,
        addedByName: (data['addedByName'] ?? '') as String,
        addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        bought: (data['bought'] ?? false) as bool,
        boughtAt: (data['boughtAt'] as Timestamp?)?.toDate(),
        boughtBy: data['boughtBy'] as String?,
        price: data['price'] as num?,
        quantity: data['quantity'] as String?,
        note: data['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': categoryId,
        'addedBy': addedBy,
        'addedByName': addedByName,
        'addedAt': Timestamp.fromDate(addedAt),
        'bought': bought,
        'boughtAt':
            boughtAt == null ? null : Timestamp.fromDate(boughtAt!),
        'boughtBy': boughtBy,
        'price': price,
        'quantity': quantity,
        'note': note,
      };

  ListItem copyWith({
    String? name,
    String? categoryId,
    bool? bought,
    DateTime? boughtAt,
    String? boughtBy,
    num? price,
    String? quantity,
    String? note,
  }) =>
      ListItem(
        id: id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        addedBy: addedBy,
        addedByName: addedByName,
        addedAt: addedAt,
        bought: bought ?? this.bought,
        boughtAt: boughtAt ?? this.boughtAt,
        boughtBy: boughtBy ?? this.boughtBy,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );
}

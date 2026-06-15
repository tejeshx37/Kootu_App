import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { percent, flat, bogo }

class Offer {
  final String id;
  final String merchantId;
  final String merchantName;
  final String description;
  final String categoryId;
  final DiscountType discountType;
  final num discountValue;
  final num savings;
  final double distanceKm;
  final double rating;
  final DateTime validUntil;
  final List<String> matchedItemNames;
  final bool nearby;

  const Offer({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.description,
    required this.categoryId,
    required this.discountType,
    required this.discountValue,
    required this.savings,
    required this.distanceKm,
    required this.rating,
    required this.validUntil,
    this.matchedItemNames = const [],
    this.nearby = false,
  });

  factory Offer.fromMap(String id, Map<String, dynamic> data) => Offer(
        id: id,
        merchantId: (data['merchantId'] ?? '') as String,
        merchantName: (data['merchantName'] ?? '') as String,
        description: (data['description'] ?? '') as String,
        categoryId: (data['category'] ?? 'other') as String,
        discountType: DiscountType.values.firstWhere(
          (e) => e.name == (data['discountType'] ?? 'percent'),
          orElse: () => DiscountType.percent,
        ),
        discountValue: (data['discountValue'] ?? 0) as num,
        savings: (data['savings'] ?? 0) as num,
        distanceKm: ((data['distanceKm'] ?? 0) as num).toDouble(),
        rating: ((data['rating'] ?? 4.5) as num).toDouble(),
        validUntil: (data['validUntil'] as Timestamp?)?.toDate() ??
            DateTime.now().add(const Duration(hours: 6)),
        nearby: (data['nearby'] ?? false) as bool,
      );
}

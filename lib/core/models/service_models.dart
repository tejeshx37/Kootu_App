/// Service catalogue types for the Explore → Services tab. These were
/// previously defined inside the mock data file; they now live here so the
/// widgets and Firestore-backed providers share one definition.

class ServiceCategory {
  final String label;
  final String emoji;
  final int bgArgb;
  const ServiceCategory(this.label, this.emoji, this.bgArgb);

  factory ServiceCategory.fromMap(Map<String, dynamic> data) => ServiceCategory(
        (data['label'] ?? '') as String,
        (data['emoji'] ?? '🛍️') as String,
        (data['bgArgb'] as num?)?.toInt() ?? 0xFFF3F4F6,
      );
}

class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final int bgArgb;
  final double rating;
  final int reviews;
  final double distanceKm;
  final int priceFrom;
  final String tagline;
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.bgArgb,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.priceFrom,
    required this.tagline,
  });

  factory ServiceProvider.fromMap(String id, Map<String, dynamic> data) =>
      ServiceProvider(
        id: id,
        name: (data['name'] ?? '') as String,
        category: (data['category'] ?? '') as String,
        emoji: (data['emoji'] ?? '🛠️') as String,
        bgArgb: (data['bgArgb'] as num?)?.toInt() ?? 0xFFF3F4F6,
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        reviews: (data['reviews'] as num?)?.toInt() ?? 0,
        distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
        priceFrom: (data['priceFrom'] as num?)?.toInt() ?? 0,
        tagline: (data['tagline'] ?? '') as String,
      );
}

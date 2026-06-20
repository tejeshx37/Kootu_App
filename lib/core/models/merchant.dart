class Merchant {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;

  const Merchant({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.address = '',
  });

  factory Merchant.fromMap(String id, Map<String, dynamic> data) => Merchant(
        id: id,
        name: (data['name'] ?? '') as String,
        lat: ((data['lat'] ?? 0) as num).toDouble(),
        lng: ((data['lng'] ?? 0) as num).toDouble(),
        address: (data['address'] ?? '') as String,
      );
}

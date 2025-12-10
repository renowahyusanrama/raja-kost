class KostModel {
  final String id;
  final String name;
  final String type;
  final int price;
  final String description;
  final List<String> images;
  final List<String> facilities;
  final String location;
  final double rating;
  final bool available;

  KostModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
    required this.images,
    required this.facilities,
    required this.location,
    required this.rating,
    required this.available,
  });

  factory KostModel.fromJson(Map<String, dynamic> json) {
    return KostModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      available: json['available'] ?? true,
    );
  }
}

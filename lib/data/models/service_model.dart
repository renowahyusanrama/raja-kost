class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String unit;
  final String icon;
  final String category;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.icon,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      unit: json['unit'] ?? '',
      icon: json['icon'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

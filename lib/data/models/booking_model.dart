class BookingModel {
  final String id;
  final DateTime createdAt;
  final String serviceId;
  final String serviceName;
  final String? roomType;
  final String? roomCode;
  final int quantity;
  final num pricePerUnit;
  final num totalPrice;
  final num discount;
  final num finalPrice;

  BookingModel({
    required this.id,
    required this.createdAt,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.discount,
    required this.finalPrice,
    this.roomType,
    this.roomCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      serviceId: json['service_id'] as String? ?? '',
      serviceName: json['service_name'] as String? ?? '',
      roomType: json['room_type'] as String?,
      roomCode: json['room_code'] as String?,
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      pricePerUnit: json['price_per_unit'] as num? ?? 0,
      totalPrice: json['total_price'] as num? ?? 0,
      discount: json['discount'] as num? ?? 0,
      finalPrice: json['final_price'] as num? ?? 0,
    );
  }
}

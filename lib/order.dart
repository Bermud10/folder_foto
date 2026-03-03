// ==================== МОДЕЛЬ ЗАКАЗА ====================
class Order {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final List<String> photoPaths;

  Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'createdAt': createdAt.toIso8601String(),
        'photoPaths': photoPaths,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        orderNumber: json['orderNumber'],
        createdAt: DateTime.parse(json['createdAt']),
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
      );
}
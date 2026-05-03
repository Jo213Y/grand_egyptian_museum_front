// lib/models/ticket_type.dart

class TicketType {
  final int id;
  final String ticketType;
  final double price;
  final String? ageRange;
  final String? description;
  int quantity;

  TicketType({
    required this.id,
    required this.ticketType,
    required this.price,
    this.ageRange,
    this.description,
    this.quantity = 0,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    // Build ageRange from min_age / max_age if not provided directly
    String? ageRange = json['ageRange'];
    if (ageRange == null) {
      final min = json['minAge'] ?? json['min_age'];
      final max = json['maxAge'] ?? json['max_age'];
      if (min != null && max != null) {
        ageRange = '$min – $max years';
      } else if (min != null) {
        ageRange = '$min+ years';
      } else if (max != null) {
        ageRange = 'Up to $max years';
      }
    }
    return TicketType(
      id:          json['id'] ?? json['typeId'] ?? 0,
      ticketType:  json['label'] ?? json['ticketType'] ?? '',
      price:       (json['price'] as num?)?.toDouble() ?? 0.0,
      ageRange:    ageRange,
      description: json['description'],
    );
  }

  String get label => ticketType;
  double get subtotal => price * quantity;
}
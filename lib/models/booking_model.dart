class TicketDetail {
  final String ticketType;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const TicketDetail({
    required this.ticketType,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> j) => TicketDetail(
    ticketType: j['ticketType'] ?? '',
    quantity: (j['quantity'] ?? 1) as int,
    unitPrice: (j['unitPrice'] as num?)?.toDouble() ?? 0.0,
    subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0.0,
  );
}

class BookingModel {
  final int? id;
  final String visitDate;
  final double totalPrice;
  final String status;
  final String? hallName;
  final List<TicketDetail> tickets;

  BookingModel({
    this.id,
    required this.visitDate,
    required this.totalPrice,
    required this.status,
    this.hallName,
    this.tickets = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) {
    return BookingModel(
      id: j['id'],
      visitDate: j['visitDate'] ?? '',
      totalPrice: (j['totalPrice'] as num).toDouble(),
      status: j['status'] ?? 'CONFIRMED',
      hallName: j['hallName'],
      tickets: (j['tickets'] as List<dynamic>? ?? [])
          .map((t) => TicketDetail.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
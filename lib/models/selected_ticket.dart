// lib/models/selected_ticket.dart
import 'ticket_type.dart';

class SelectedTicket {
  final TicketType ticket;
  int quantity;

  SelectedTicket({
    required this.ticket,
    this.quantity = 0,
  });

  double get subtotal => ticket.price * quantity;

  // getters مختصرة للوصول السريع
  String get label => ticket.label;
  double get price => ticket.price;
  String get ageRange => ticket.ageRange ?? '';
  int get id => ticket.id;
}
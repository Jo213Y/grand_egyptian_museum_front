import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import 'package:grand_egyptian_museum/widgets/drawerItem.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_assets.dart';
import '../models/ticket_type.dart';
import '../models/selected_ticket.dart';
import '../services/api_service.dart';
import '../widgets/step_cirrcle.dart';
import '../widgets/ticket_counter.dart';
import 'admin/admin_dashboard_screen.dart';
import 'halls_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final int? preselectedHallId;

  const BookingScreen({super.key, this.preselectedHallId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int step = 1;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime calendarMonth = DateTime.now();

  List<SelectedTicket> selectedTickets = [];
  bool loadingTickets = true;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    final ticketTypes = await ApiService.getTicketTypes();
    print('DEBUG: ${ticketTypes.map((t) => {'label': t.ticketType, 'age': t.ageRange, 'desc': t.description}).toList()}');

    setState(() {
      selectedTickets = ticketTypes
          .map((ticket) => SelectedTicket(ticket: ticket))
          .toList();
      loadingTickets = false;
    });
  }

  double get totalPrice => selectedTickets.fold(
      0.0, (sum, item) => sum + (item.ticket.price * item.quantity));

  int get totalCount =>
      selectedTickets.fold(0, (sum, item) => sum + item.quantity);

  String get formattedDate =>
      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

  String get ticketSummary {
    final parts = selectedTickets
        .where((t) => t.quantity > 0)
        .map((t) => '${t.ticket.label} (${t.quantity})')
        .toList();

    return parts.isEmpty ? 'None selected' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GemAppBar(
        activePage: 'Ticket',
      ),
      endDrawer: const AppDrawer(),
      body: GemBackground(
        imageAsset: AppAssets.bgMuseum,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: loadingTickets
                    ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.gold),
                )
                    : buildBody(),
              ),
              buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── BODY ─────────────────────────

  Widget buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Book Your Visit',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          buildSteps(),
          const SizedBox(height: 20),

          buildTicketSelector(),
        ],
      ),
    );
  }

  Widget buildSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepCircle(number: 1, active: step >= 1),
        Expanded(child: Divider(color: AppColors.primaryLight)),
        StepCircle(number: 2, active: step >= 2),
        Expanded(child: Divider(color: AppColors.primaryLight)),
        StepCircle(number: 3, active: step >= 3),
      ],
    );
  }

  // ───────────────────────── TICKETS ─────────────────────────

  Widget buildTicketSelector() {
    return GemCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Select Tickets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...selectedTickets.map(
                (item) => TicketCounter(
              title: item.ticket.label,
              ageRange: item.ticket.ageRange ?? '',
              description: item.ticket.description ?? '',  // ← ضيف السطر ده
              price: '\$${item.ticket.price}',
              count: item.quantity,
              onIncrement: () {
                setState(() => item.quantity++);
              },
              onDecrement: () {
                setState(() {
                  if (item.quantity > 0) item.quantity--;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BOTTOM BAR ─────────────────────────

  Widget buildBottomBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tickets details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Date: $formattedDate',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Tickets: $ticketSummary',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Price: \$${totalPrice.toInt()}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: totalCount > 0
                ? () {
              setState(() => step = 2);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    visitDate: formattedDate,
                    tickets: selectedTickets,
                    totalPrice: totalPrice,
                    hallId: widget.preselectedHallId,
                  ),
                ),
              );
            }
                : null,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                totalCount > 0 ? AppColors.primary : AppColors.gray,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
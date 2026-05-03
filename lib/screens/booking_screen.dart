import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import 'package:grand_egyptian_museum/widgets/drawerItem.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_assets.dart';
import '../models/ticket_type.dart';
import '../models/selected_ticket.dart';
import '../models/booking_model.dart';
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

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // ── New Booking state ──
  int step = 1;
  List<SelectedTicket> selectedTickets = [];
  bool loadingTickets = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    loadTickets();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> loadTickets() async {
    final ticketTypes = await ApiService.getTicketTypes();
    setState(() {
      selectedTickets =
          ticketTypes.map((t) => SelectedTicket(ticket: t)).toList();
      loadingTickets = false;
    });
  }

  double get totalPrice =>
      selectedTickets.fold(0.0, (s, i) => s + i.ticket.price * i.quantity);

  int get totalCount =>
      selectedTickets.fold(0, (s, i) => s + i.quantity);

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
      appBar: const GemAppBar(activePage: 'Ticket'),
      endDrawer: const AppDrawer(),
      body: GemBackground(
        imageAsset: AppAssets.bgMuseum,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ── TabBar ────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline, size: 18),
                          SizedBox(width: 6),
                          Text('New Booking',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long, size: 18),
                          SizedBox(width: 6),
                          Text('My Bookings',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── TabBarView ────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // ── Tab 1: New Booking ────────────
                    _NewBookingTab(
                      loadingTickets: loadingTickets,
                      selectedTickets: selectedTickets,
                      ticketSummary: ticketSummary,
                      totalPrice: totalPrice,
                      totalCount: totalCount,
                      preselectedHallId: widget.preselectedHallId,
                      onQuantityChanged: () => setState(() {}),
                    ),
                    // ── Tab 2: My Bookings ────────────
                    const _MyBookingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 1: New Booking ────────────────────────────────────────────────────────
class _NewBookingTab extends StatefulWidget {
  final bool loadingTickets;
  final List<SelectedTicket> selectedTickets;
  final String ticketSummary;
  final double totalPrice;
  final int totalCount;
  final int? preselectedHallId;
  final VoidCallback onQuantityChanged;

  const _NewBookingTab({
    required this.loadingTickets,
    required this.selectedTickets,
    required this.ticketSummary,
    required this.totalPrice,
    required this.totalCount,
    required this.preselectedHallId,
    required this.onQuantityChanged,
  });

  @override
  State<_NewBookingTab> createState() => _NewBookingTabState();
}

class _NewBookingTabState extends State<_NewBookingTab> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  String get _formattedDate =>
      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A0A00),
              onSurface: Color(0xFFF5D896),
            ),
            dialogBackgroundColor: const Color(0xFF1A0A00),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.loadingTickets
              ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
              : SingleChildScrollView(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StepCircle(number: 1, active: true),
                    Expanded(
                        child: Divider(color: AppColors.primaryLight)),
                    StepCircle(number: 2, active: false),
                    Expanded(
                        child: Divider(color: AppColors.primaryLight)),
                    StepCircle(number: 3, active: false),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Date Picker Card ──────────────────────
                GemCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Visit Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFC8A96E)
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: AppColors.gold, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formattedDate,
                                  style: const TextStyle(
                                    color: Color(0xFFF5D896),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: AppColors.gold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tickets Card ──────────────────────────
                GemCard(
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
                      ...widget.selectedTickets.map(
                            (item) => TicketCounter(
                          title: item.ticket.label,
                          ageRange: item.ticket.ageRange ?? '',
                          description: item.ticket.description ?? '',
                          price: '\$${item.ticket.price}',
                          count: item.quantity,
                          onIncrement: () {
                            item.quantity++;
                            widget.onQuantityChanged();
                          },
                          onDecrement: () {
                            if (item.quantity > 0) item.quantity--;
                            widget.onQuantityChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom Bar ──────────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tickets details',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Date: $_formattedDate',
                        style: const TextStyle(color: Colors.white70)),
                    Text('Tickets: ${widget.ticketSummary}',
                        style: const TextStyle(color: Colors.white70)),
                    Text('Price: \$${widget.totalPrice.toInt()}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.totalCount > 0
                    ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      visitDate: _formattedDate,
                      tickets: widget.selectedTickets,
                      totalPrice: widget.totalPrice,
                      hallId: widget.preselectedHallId,
                    ),
                  ),
                )
                    : null,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.totalCount > 0
                        ? AppColors.primary
                        : AppColors.gray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab 2: My Bookings ────────────────────────────────────────────────────────
class _MyBookingsTab extends StatefulWidget {
  const _MyBookingsTab();

  @override
  State<_MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<_MyBookingsTab>
    with AutomaticKeepAliveClientMixin {
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMyBookings();
      setState(() {
        _bookings = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A00),
        title: const Text('Delete Booking',
            style: TextStyle(color: Color(0xFFC8A96E))),
        content: const Text(
            'This will permanently delete the booking record. Continue?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteBooking(id);
      _load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
    }
  }

  Future<void> _cancel(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A00),
        title: const Text('Cancel Booking',
            style: TextStyle(color: Color(0xFFC8A96E))),
        content: const Text('Are you sure you want to cancel this booking?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.cancelBooking(id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (_bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('No bookings yet',
                style: TextStyle(color: Colors.white38, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _bookings.length,
        itemBuilder: (_, i) => _BookingTicketCard(
          booking: _bookings[i],
          onCancel: _bookings[i].status.toUpperCase() == 'CONFIRMED'
              ? () => _cancel(context, _bookings[i].id!)
              : null,
          onDelete: () => _delete(context, _bookings[i].id!),
        ),
      ),
    );
  }
}

// ── Booking Ticket Card ───────────────────────────────────────────────────────
class _BookingTicketCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;
  final VoidCallback onDelete;

  const _BookingTicketCard({
    required this.booking,
    required this.onDelete,
    this.onCancel,
  });

  Color get _statusColor {
    switch (booking.status.toUpperCase()) {
      case 'CONFIRMED': return const Color(0xFF4CAF50);
      case 'CANCELLED': return Colors.redAccent;
      case 'COMPLETED': return Colors.blueAccent;
      default:          return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A00),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8A96E).withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EGYPTIAN MUSEUM',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Color(0xFFC8A96E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #${booking.id ?? '-'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFF5D896),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Details ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _field('Visit Date', booking.visitDate),
                    const SizedBox(width: 12),
                    _field('Total Price',
                        'EGP ${booking.totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
                if (booking.tickets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...booking.tickets.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        _field('Ticket Type', t.ticketType),
                        const SizedBox(width: 12),
                        _field('Qty x Price',
                            'x${t.quantity}  •  EGP ${t.unitPrice.toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),

          // ── Divider ─────────────────────────────────
          Row(
            children: [
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: DashedDivider(),
              ),
              Transform.translate(
                offset: const Offset(8, 0),
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // ── Footer ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOOKING CODE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: Color(0xFFC8A96E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'MUS-${(booking.id ?? 0).toString().padLeft(6, '0')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFF5D896),
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (onCancel != null) ...[
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined,
                        color: Colors.redAccent, size: 16),
                    label: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      side: const BorderSide(
                          color: Colors.redAccent, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white38, size: 20),
                  tooltip: 'Delete booking',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    side: const BorderSide(color: Colors.white24, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: Color(0xFFC8A96E),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFF5D896),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Dashed Divider ────────────────────────────────────────────────────────────
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      const dashW = 6.0;
      const gap = 4.0;
      final count = (constraints.maxWidth / (dashW + gap)).floor();
      return Row(
        children: List.generate(count, (_) => Padding(
          padding: const EdgeInsets.only(right: gap),
          child: Container(
            width: dashW, height: 1,
            color: const Color(0xFFC8A96E).withOpacity(0.4),
          ),
        )),
      );
    });
  }
}
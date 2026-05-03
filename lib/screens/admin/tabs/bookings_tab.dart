import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAllBookings();
      setState(() { _bookings = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> get _filtered {
    if (_search.isEmpty) return _bookings;
    final q = _search.toLowerCase();
    return _bookings.where((b) =>
    (b['userEmail'] ?? '').toLowerCase().contains(q) ||
        (b['userName'] ?? '').toLowerCase().contains(q) ||
        (b['status'] ?? '').toLowerCase().contains(q) ||
        (b['id']?.toString() ?? '').contains(q)
    ).toList();
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'COMPLETED': return Colors.blue;
      default:          return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search Bar ──────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by user or status...',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gold)),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () => setState(() => _search = ''))
                  : null,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        // ── Stats Row ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              _statChip('Total', _bookings.length.toString(), Colors.white54),
              const SizedBox(width: 8),
              _statChip('Confirmed',
                  _bookings.where((b) => (b['status'] ?? '').toUpperCase() == 'CONFIRMED').length.toString(),
                  Colors.green),
              const SizedBox(width: 8),
              _statChip('Cancelled',
                  _bookings.where((b) => (b['status'] ?? '').toUpperCase() == 'CANCELLED').length.toString(),
                  Colors.red),
            ],
          ),
        ),

        // ── List ────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : _filtered.isEmpty
              ? const Center(child: Text('No bookings found',
              style: TextStyle(color: Colors.white38)))
              : RefreshIndicator(
            onRefresh: _load,
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _AdminBookingCard(
                booking: _filtered[i],
                statusColor: _statusColor(_filtered[i]['status'] ?? ''),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Admin Booking Card ────────────────────────────────────────────────────────
class _AdminBookingCard extends StatefulWidget {
  final dynamic booking;
  final Color statusColor;
  const _AdminBookingCard({required this.booking, required this.statusColor});

  @override
  State<_AdminBookingCard> createState() => _AdminBookingCardState();
}

class _AdminBookingCardState extends State<_AdminBookingCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final color = widget.statusColor;
    final tickets = (b['tickets'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withOpacity(0.15),
                    child: Text((b['userName'] ?? '?')[0].toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['userName'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(b['userEmail'] ?? '',
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.calendar_today, color: Colors.white24, size: 11),
                          const SizedBox(width: 4),
                          Text('Visit: ${b['visitDate'] ?? '-'}',
                              style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('EGP ${(b['totalPrice'] as num?)?.toStringAsFixed(0) ?? '-'}',
                          style: const TextStyle(color: AppColors.gold,
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(b['status'] ?? '',
                            style: TextStyle(color: color, fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white24, size: 18),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking ID
                  Row(children: [
                    const Icon(Icons.tag, color: Colors.white24, size: 13),
                    const SizedBox(width: 6),
                    Text('Booking ID: ${b['id'] ?? '-'}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                  const SizedBox(height: 10),

                  // Tickets
                  if (tickets.isNotEmpty) ...[
                    const Text('Tickets',
                        style: TextStyle(color: AppColors.gold, fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...tickets.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        const Icon(Icons.confirmation_number,
                            color: Colors.white24, size: 13),
                        const SizedBox(width: 6),
                        Expanded(child: Text(t['ticketType'] ?? '',
                            style: const TextStyle(color: Colors.white60, fontSize: 12))),
                        Text('x${t['quantity'] ?? 1}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(width: 10),
                        Text('EGP ${(t['subtotal'] as num?)?.toStringAsFixed(0) ?? '-'}',
                            style: const TextStyle(color: AppColors.gold, fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
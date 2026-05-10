import 'package:flutter/material.dart';
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
  DateTime? _filterDate;
  String? _filterTicketType;

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

  List<String> get _allTicketTypes {
    final types = <String>{};
    for (final b in _bookings) {
      for (final t in (b['tickets'] as List<dynamic>?) ?? []) {
        final type = t['ticketType'] as String?;
        if (type != null && type.isNotEmpty) types.add(type);
      }
    }
    return types.toList()..sort();
  }

  List<dynamic> get _filtered {
    return _bookings.where((b) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!((b['userEmail'] ?? '').toLowerCase().contains(q) ||
            (b['userName'] ?? '').toLowerCase().contains(q) ||
            (b['status'] ?? '').toLowerCase().contains(q) ||
            (b['id']?.toString() ?? '').contains(q))) return false;
      }
      if (_filterDate != null) {
        final visitDate = b['visitDate'] as String?;
        if (visitDate == null || visitDate.isEmpty) return false;
        try {
          DateTime bDate;
          if (visitDate.contains('-')) {
            bDate = DateTime.parse(visitDate); // yyyy-MM-dd
          } else {
            final parts = visitDate.split('/');
            bDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
          if (bDate.year != _filterDate!.year || bDate.month != _filterDate!.month || bDate.day != _filterDate!.day) return false;
        } catch (_) { return false; }
      }
      if (_filterTicketType != null) {
        final tickets = (b['tickets'] as List<dynamic>?) ?? [];
        if (!tickets.any((t) => t['ticketType'] == _filterTicketType)) return false;
      }
      return true;
    }).toList();
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'COMPLETED': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary, onPrimary: Colors.white,
            surface: Color(0xFF1A0A00), onSurface: Color(0xFFF5D896),
          ),
          dialogBackgroundColor: const Color(0xFF1A0A00),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  bool get _hasFilters => _filterDate != null || _filterTicketType != null || _search.isNotEmpty;
  void _clearFilters() => setState(() { _search = ''; _filterDate = null; _filterTicketType = null; });

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by user or status...',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold)),
              suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.white38, size: 18), onPressed: () => setState(() => _search = '')) : null,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        // Filter Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              // Date filter
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _filterDate != null ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _filterDate != null ? AppColors.primary.withOpacity(0.6) : Colors.white12),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today, color: _filterDate != null ? AppColors.gold : Colors.white30, size: 15),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _filterDate != null ? '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}' : 'Filter by date',
                          style: TextStyle(color: _filterDate != null ? AppColors.gold : Colors.white30, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_filterDate != null)
                        GestureDetector(onTap: () => setState(() => _filterDate = null), child: const Icon(Icons.close, color: Colors.white38, size: 14)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Ticket type dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _filterTicketType != null ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _filterTicketType != null ? AppColors.primary.withOpacity(0.6) : Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _filterTicketType,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A0A00),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      icon: Icon(Icons.arrow_drop_down, color: _filterTicketType != null ? AppColors.gold : Colors.white30, size: 18),
                      hint: const Text('Filter by type', style: TextStyle(color: Colors.white30, fontSize: 12)),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('All types', style: TextStyle(color: Colors.white54, fontSize: 12))),
                        ..._allTicketTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(children: [
                            const Icon(Icons.confirmation_number, color: AppColors.gold, size: 13),
                            const SizedBox(width: 6),
                            Flexible(child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ]),
                        )),
                      ],
                      onChanged: (v) => setState(() => _filterTicketType = v),
                    ),
                  ),
                ),
              ),

              // Clear all
              if (_hasFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.filter_alt_off, color: Colors.redAccent, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Active filter labels
        if (_filterDate != null || _filterTicketType != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              const Icon(Icons.filter_list, color: Colors.white30, size: 13),
              const SizedBox(width: 6),
              if (_filterDate != null) _filterLabel(
                '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}',
                AppColors.primary, () => setState(() => _filterDate = null),
              ),
              if (_filterDate != null && _filterTicketType != null) const SizedBox(width: 6),
              if (_filterTicketType != null) _filterLabel(
                _filterTicketType!, AppColors.gold,
                    () => setState(() => _filterTicketType = null),
              ),
            ]),
          ),

        // Stats Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            _statChip('Total', filtered.length.toString(), Colors.white54),
            const SizedBox(width: 8),
            _statChip('Confirmed', filtered.where((b) => (b['status'] ?? '').toUpperCase() == 'CONFIRMED').length.toString(), Colors.green),
            const SizedBox(width: 8),
            _statChip('Cancelled', filtered.where((b) => (b['status'] ?? '').toUpperCase() == 'CANCELLED').length.toString(), Colors.red),
          ]),
        ),

        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_off, color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text(_hasFilters ? 'No bookings match the filters' : 'No bookings found', style: const TextStyle(color: Colors.white38)),
            if (_hasFilters) ...[
              const SizedBox(height: 10),
              TextButton.icon(onPressed: _clearFilters, icon: const Icon(Icons.clear, color: AppColors.gold, size: 16), label: const Text('Clear filters', style: TextStyle(color: AppColors.gold))),
            ],
          ]))
              : RefreshIndicator(
            onRefresh: _load,
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _AdminBookingCard(
                booking: filtered[i],
                statusColor: _statusColor(filtered[i]['status'] ?? ''),
                highlightType: _filterTicketType,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterLabel(String text, Color color, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(width: 5),
        GestureDetector(onTap: onRemove, child: Icon(Icons.close, color: color.withOpacity(0.7), size: 12)),
      ]),
    );
  }

  Widget _statChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]),
    );
  }
}

// ── Admin Booking Card ────────────────────────────────────────────────────────
class _AdminBookingCard extends StatefulWidget {
  final dynamic booking;
  final Color statusColor;
  final String? highlightType;
  const _AdminBookingCard({required this.booking, required this.statusColor, this.highlightType});
  @override
  State<_AdminBookingCard> createState() => _AdminBookingCardState();
}

class _AdminBookingCardState extends State<_AdminBookingCard> {
  bool _expanded = true;

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
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.15),
                  child: Text((b['userName'] ?? '?')[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b['userName'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(b['userEmail'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.calendar_today, color: Colors.white24, size: 11),
                  const SizedBox(width: 4),
                  Text('Visit: ${b['visitDate'] ?? '-'}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('EGP ${(b['totalPrice'] as num?)?.toStringAsFixed(0) ?? '-'}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                  child: Text(b['status'] ?? '', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(width: 6),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white24, size: 18),
            ]),
          ),
        ),

        if (_expanded) ...[
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.tag, color: Colors.white24, size: 13),
                const SizedBox(width: 6),
                Text('Booking ID: ${b['id'] ?? '-'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
              if (tickets.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Tickets', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...tickets.map((t) {
                  final isHighlighted = widget.highlightType != null && t['ticketType'] == widget.highlightType;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: isHighlighted ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : EdgeInsets.zero,
                    decoration: isHighlighted ? BoxDecoration(
                      color: AppColors.gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ) : null,
                    child: Row(children: [
                      Icon(Icons.confirmation_number, color: isHighlighted ? AppColors.gold : Colors.white24, size: 13),
                      const SizedBox(width: 6),
                      Expanded(child: Text(t['ticketType'] ?? '',
                          style: TextStyle(color: isHighlighted ? AppColors.gold : Colors.white60, fontSize: 12, fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal))),
                      Text('x${t['quantity'] ?? 1}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(width: 10),
                      Text('EGP ${(t['subtotal'] as num?)?.toStringAsFixed(0) ?? '-'}',
                          style: TextStyle(color: isHighlighted ? AppColors.gold : AppColors.gold.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  );
                }),
              ],
            ]),
          ),
        ],
      ]),
    );
  }
}
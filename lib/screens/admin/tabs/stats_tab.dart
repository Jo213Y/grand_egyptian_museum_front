import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/models/admin_stats.dart';
import 'package:grand_egyptian_museum/models/ticket_type.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';
import 'package:grand_egyptian_museum/theme/app_theme.dart';
import 'package:grand_egyptian_museum/utils/app_events.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  AdminStats? dashboard;
  List<TicketType> tickets = [];

  bool loading = true;
  String? error; // ✅ نعرض الـ error الحقيقي
  late StreamSubscription stream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadData();

    // 🔄 Refresh every 30 seconds automatically
   // _timer = Timer.periodic(const Duration(seconds: 30), (_) => loadData());

    stream = AppEvents.stream.listen((event) {
      if (event == AppEventTypes.statsUpdated ||
          event == AppEventTypes.usersUpdated ||
          event == AppEventTypes.hallsUpdated) {
        loadData();
      }
    });
  }

  Future<void> loadData() async {
    setState(() { loading = true; error = null; });
    try {
      final statsData  = await ApiService.getStatistics();
      final ticketsData = await ApiService.getTicketTypes();

      setState(() {
        dashboard = statsData;
        tickets   = ticketsData;
        loading   = false;
      });
    } catch (e) {
      // ✅ بنعرض الـ error الحقيقي بدل demo
      setState(() {
        error   = e.toString();
        loading = false;
      });
      debugPrint('❌ StatsTab error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    // ✅ لو فيه error نعرضه بدل ما نخبي المشكلة
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = dashboard!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _bigCard("Users",    data.totalUsers.toString(),    Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _bigCard("Tickets",  data.totalTickets.toString(),  Icons.confirmation_number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _bigCard("Revenue",  "EGP ${data.totalRevenue.toStringAsFixed(0)}", Icons.attach_money)),
              const SizedBox(width: 12),
              Expanded(child: _bigCard("Bookings", data.totalBookings.toString(), Icons.event)),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle("Ticket Analytics"),
          const SizedBox(height: 10),
          ...tickets.map((ticket) {
            // match case-insensitively — backend may return "Adult" or "ADULT"
            final key = data.ticketsByType.keys.firstWhere(
                  (k) => k.toUpperCase() == ticket.ticketType.toUpperCase(),
              orElse: () => '',
            );
            final value   = key.isEmpty ? 0 : (data.ticketsByType[key] ?? 0);
            final percent = data.totalTickets == 0 ? 0.0 : value / data.totalTickets;
            return _ticketRow(
              label:   ticket.ticketType,
              value:   value,
              percent: percent,
              color:   AppColors.gold,
            );
          }),
        ],
      ),
    );
  }

  Widget _bigCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text(value, style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _ticketRow({required String label, required int value, required double percent, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Text("$value  (${(percent * 100).toStringAsFixed(1)}%)",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percent, backgroundColor: Colors.white10, color: color),
        ],
      ),
    );
  }


}
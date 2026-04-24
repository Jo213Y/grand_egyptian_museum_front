import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';
import 'package:grand_egyptian_museum/theme/app_theme.dart';
import 'package:grand_egyptian_museum/utils/app_events.dart';

class LogsTab extends StatefulWidget {
  const LogsTab({super.key});

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  List logs = [];
  bool loading = true;

  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    load();

    sub = AppEvents.stream.listen((event) {
      if (event == AppEventTypes.logsUpdated) {
        load();
      }
    });
  }

  Future<void> load() async {
    final l = await ApiService.getAdminLogs();
    setState(() {
      logs = l;
      loading = false;
    });
  }

  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';

    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);

      if (diff.inDays > 0) {
        return "${date.year}-${date.month}-${date.day}";
      } else if (diff.inHours > 0) {
        return "${diff.inHours} hours ago";
      } else if (diff.inMinutes > 0) {
        return "${diff.inMinutes} min ago";
      } else {
        return "now";
      }
    } catch (_) {
      return '—';
    }
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final l = logs[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(child: Text(l['adminName'] ?? '—', style: const TextStyle(color: Colors.white))),
              Expanded(child: Text(l['action'] ?? '—', style: const TextStyle(color: AppColors.gold))),
              Expanded(child: Text(l['targetDescription'] ?? '—', style: const TextStyle(color: Colors.white70))),
              Text(formatTime(l['createdAt']),
                  style: const TextStyle(color: Colors.white38)),
            ],
          ),
        );
      },
    );
  }
}
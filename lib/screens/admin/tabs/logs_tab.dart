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
  List<Map<String, dynamic>> logs = [];
  bool loading = true;
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    load();
    sub = AppEvents.stream.listen((e) {
      if (e == AppEventTypes.logsUpdated) load();
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final l = await ApiService.getAdminLogs();
      setState(() {
        logs    = List<Map<String, dynamic>>.from(l);
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  // ── helpers ─────────────────────────────────────────────
  String _formatTime(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      final d = DateTime.parse(s).toLocal();
      return '${d.year}-${_p(d.month)}-${_p(d.day)}  ${_p(d.hour)}:${_p(d.minute)}:${_p(d.second)}';
    } catch (_) { return '—'; }
  }
  String _p(int n) => n.toString().padLeft(2, '0');

  // Extract target (the thing the action was done on) from detail string
  String _extractTarget(String? detail, String? action) {
    if (detail == null || detail.isEmpty) return '—';
    final d = detail.split('| Reason:').first.trim();
    // e.g. "Blocked user: joe@gmail.com" → "joe@gmail.com"
    if (d.contains(':')) return d.split(':').sublist(1).join(':').trim();
    return d;
  }

  String? _extractReason(String? detail) {
    if (detail == null || !detail.contains('| Reason:')) return null;
    final r = detail.split('| Reason:').last.trim();
    return r.isEmpty ? null : r;
  }

  _ActionStyle _styleFor(String? action) {
    switch ((action ?? '').toUpperCase()) {
      case 'BLOCK_USER':   return _ActionStyle(Icons.block,               Colors.redAccent,    'Blocked User');
      case 'UNBLOCK_USER': return _ActionStyle(Icons.lock_open,           Colors.greenAccent,  'Unblocked User');
      case 'ADD_ADMIN':    return _ActionStyle(Icons.admin_panel_settings, AppColors.gold,      'Added Admin');
      case 'DELETE_USER':  return _ActionStyle(Icons.delete_forever,       Colors.orangeAccent, 'Deleted User');
      case 'UPDATE_HALL':  return _ActionStyle(Icons.edit,                 Colors.blueAccent,   'Updated Hall');
      default:             return _ActionStyle(Icons.info_outline,          Colors.white54,      action ?? '—');
    }
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppColors.gold));

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activity Log',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${logs.length} action${logs.length == 1 ? '' : 's'} recorded',
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              // Legend chips
              Wrap(
                spacing: 6,
                children: [
                  _legendChip(Colors.redAccent,    'Block'),
                  _legendChip(Colors.greenAccent,  'Unblock'),
                  _legendChip(AppColors.gold,      'Admin'),
                  _legendChip(Colors.orangeAccent, 'Delete'),
                ],
              ),
            ],
          ),
        ),

        // ── List ────────────────────────────────────────────
        Expanded(
          child: logs.isEmpty
              ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text('No activity logs yet', style: TextStyle(color: Colors.white38)),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: load,
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: logs.length,
              itemBuilder: (_, i) => _logCard(logs[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logCard(Map<String, dynamic> l) {
    final style  = _styleFor(l['action']);
    final name   = l['adminName'] ?? l['adminEmail'] ?? '—';
    final target = _extractTarget(l['detail'], l['action']);
    final reason = _extractReason(l['detail']);
    final time   = _formatTime(l['timestamp']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // ── Card Header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: style.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: style.color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(style.label,
                      style: TextStyle(color: style.color, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                // Full date + time
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white38, size: 13),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // ── Card Body ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Admin name + Target in one row
                Row(
                  children: [
                    Expanded(child: _infoRow(Icons.person,      AppColors.gold,  'Admin',  name)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoRow(Icons.manage_accounts, style.color, 'Target', target)),
                  ],
                ),

                // Reason
                if (reason != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 8),
                        const Text('Reason: ', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(reason, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _ActionStyle {
  final IconData icon;
  final Color    color;
  final String   label;
  const _ActionStyle(this.icon, this.color, this.label);
}
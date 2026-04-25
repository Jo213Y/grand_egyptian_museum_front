import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';
import 'package:grand_egyptian_museum/theme/app_theme.dart';
import 'package:grand_egyptian_museum/utils/app_events.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<Map<String, dynamic>> admins  = [];
  List<Map<String, dynamic>> users   = [];
  List<Map<String, dynamic>> blocked = [];
  bool loading  = true;
  int  tab      = 0; // 0=Users, 1=Admins, 2=Blocked

  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    load();
    sub = AppEvents.stream.listen((e) {
      if (e == AppEventTypes.usersUpdated) load();
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final all  = await ApiService.getAdminUsers();
      final list = List<Map<String, dynamic>>.from(all);
      setState(() {
        admins  = list.where((u) => (u['role'] ?? '').toString().toUpperCase() == 'ADMIN').toList();
        blocked = list.where((u) => (u['role'] ?? '').toString().toUpperCase() == 'BLOCK').toList();
        users   = list.where((u) {
          final r = (u['role'] ?? '').toString().toUpperCase();
          return r == 'USER';
        }).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleBlock(Map<String, dynamic> u) async {
    final id      = u['id'];
    final isBlock = (u['role'] ?? '').toString().toUpperCase() == 'BLOCK';

    if (isBlock) {
      // ── Unblock: simple confirm ──────────────────────────
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A0A00),
          title: const Text('Unblock User', style: TextStyle(color: AppColors.gold)),
          content: Text('Unblock "${u['fullName']}"?',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            TextButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('Unblock', style: TextStyle(color: Colors.green))),
          ],
        ),
      );
      if (confirm != true) return;
    } else {
      // ── Block: ask for reason first ──────────────────────
      final reasonCtrl = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A0A00),
          title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Block "${u['fullName']}"?',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              const Text('Reason for blocking:',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                autofocus: true,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of terms...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () {
                final r = reasonCtrl.text.trim();
                if (r.isEmpty) return; // must enter reason
                Navigator.pop(context, r);
              },
              child: const Text('Block', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (reason == null) return;
    }

    try {
      await ApiService.toggleBlockUser(id);
      // move to blocked tab automatically when blocking
      if (!isBlock && mounted) setState(() => tab = 2);
      AppEvents.emit(AppEventTypes.usersUpdated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: \$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(String? d) =>
      (d != null && d.length >= 10) ? d.substring(0, 10) : '—';

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    final list = tab == 1 ? admins : tab == 2 ? blocked : users;

    return Column(
      children: [
        // ── Toggle ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _toggleBtn('Users',   Icons.person,               users.length,   tab == 0, () => setState(() => tab = 0)),
              const SizedBox(width: 8),
              _toggleBtn('Admins',  Icons.admin_panel_settings, admins.length,  tab == 1, () => setState(() => tab = 1)),
              const SizedBox(width: 8),
              _toggleBtn('Blocked', Icons.block,                blocked.length, tab == 2, () => setState(() => tab = 2)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: list.isEmpty
              ? Center(child: Text(
              tab == 1 ? 'No admins found' : tab == 2 ? 'No blocked users' : 'No users found',
              style: const TextStyle(color: Colors.white54)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) => _userCard(list[i]),
          ),
        ),
      ],
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final role     = (u['role'] ?? '').toString().toUpperCase();
    final isBlocked = role == 'BLOCK';
    final isAdmin   = role.contains('ADMIN');

    // ID field: SSN for Egyptians, passport for foreigners
    final idLabel = u['ssn'] != null ? 'SSN' : 'Passport';
    final idValue = u['ssn'] ?? u['passportNumber'] ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? Colors.red.withOpacity(0.5)
              : AppColors.primaryLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isBlocked
                    ? Colors.red.withOpacity(0.2)
                    : isAdmin
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.white10,
                child: Icon(
                  isBlocked ? Icons.block : isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isBlocked ? Colors.redAccent : isAdmin ? AppColors.gold : Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['fullName'] ?? '—',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(u['email'] ?? '—',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (isBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('BLOCKED', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),

          // ── Info grid ──
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _infoChip(Icons.phone,        'Phone',       u['phone']       ?? '—'),
              _infoChip(Icons.flag,         'Nationality', u['nationality'] ?? '—'),
              _infoChip(Icons.badge,        idLabel,       idValue),
              _infoChip(Icons.confirmation_number, 'Tickets', '${u['ticketsBooked'] ?? 0}'),
              _infoChip(Icons.calendar_today, 'Joined',    _formatDate(u['createdAt'])),
            ],
          ),

          // ── Block button (only for non-admins) ──
          if (!isAdmin) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _toggleBlock(u),
                icon: Icon(
                  isBlocked ? Icons.lock_open : Icons.block,
                  size: 16,
                  color: isBlocked ? Colors.green : Colors.redAccent,
                ),
                label: Text(
                  isBlocked ? 'Unblock' : 'Block',
                  style: TextStyle(
                    color: isBlocked ? Colors.green : Colors.redAccent,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gold),
          const SizedBox(width: 5),
          Text('$label: ', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value,       style: const TextStyle(color: Colors.white,   fontSize: 11)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, IconData icon, int count, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.primaryLight.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : Colors.white54),
              const SizedBox(width: 6),
              Text('$label ($count)',
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
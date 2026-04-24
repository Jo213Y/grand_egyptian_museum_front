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
  List admins = [];
  List users = [];
  List allList = []; // 👈 مهم للـ debug
  bool loading = true;
  bool showAdmins = false;

  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    load();

    sub = AppEvents.stream.listen((event) {
      if (event == AppEventTypes.usersUpdated) load();
    });
  }

  Future<void> load() async {
    try {
      final all = await ApiService.getAdminUsers();
      final list = List<Map<String, dynamic>>.from(all);

      print("🔥 USERS RESPONSE: $list"); // 👈 debug

      setState(() {
        allList = list;

        admins = list.where((u) {
          final role = (u['role'] ?? '').toString().toUpperCase();
          return role.contains('ADMIN'); // 👈 أهم تعديل
        }).toList();

        users = list.where((u) {
          final role = (u['role'] ?? '').toString().toUpperCase();
          return !role.contains('ADMIN');
        }).toList();

        loading = false;
      });
    } catch (e) {
      print("❌ ERROR: $e");
      setState(() {
        admins = [];
        users = [];
        loading = false;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '—';
    return date.substring(0, 10);
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }

    final list = showAdmins ? admins : users;

    return Column(
      children: [
        // ── Toggle Buttons ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _toggleBtn(
                label: 'Users',
                icon: Icons.person,
                count: users.length,
                active: !showAdmins,
                onTap: () => setState(() => showAdmins = false),
              ),
              const SizedBox(width: 10),
              _toggleBtn(
                label: 'Admins',
                icon: Icons.admin_panel_settings,
                count: admins.length,
                active: showAdmins,
                onTap: () => setState(() => showAdmins = true),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── List ──
        Expanded(
          child: list.isEmpty
              ? Center(
            child: Text(
              showAdmins ? 'No admins found' : 'No users found',
              style: const TextStyle(color: Colors.white54),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final u = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                      AppColors.primaryLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: showAdmins
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.white10,
                      child: Icon(
                        showAdmins
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: showAdmins
                            ? AppColors.gold
                            : Colors.white54,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(u['fullName'] ?? '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold)),
                          Text(u['email'] ?? '—',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(formatDate(u['createdAt']),
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _toggleBtn({
    required String label,
    required IconData icon,
    required int count,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppColors.primary
                  : AppColors.primaryLight.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.white : Colors.white54),
              const SizedBox(width: 6),
              Text(
                '$label ($count)',
                style: TextStyle(
                  color: active ? Colors.white : Colors.white54,
                  fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import 'package:grand_egyptian_museum/widgets/common_widgets.dart';
import 'package:grand_egyptian_museum/widgets/drawerItem.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../utils/app_assets.dart';

import '../booking_screen.dart';
import '../halls_screen.dart';
import '../home_screen.dart';

import 'tabs/stats_tab.dart';
import 'tabs/users_tab.dart';
import 'tabs/hall_edit_tab.dart';
import 'tabs/logs_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GemAppBar(
        activePage: 'Dashboard',
      ),
      endDrawer: const AppDrawer(),
      body: GemBackground(
        imageAsset: AppAssets.bgMuseum,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🔹 Tabs
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
                      iconMargin: EdgeInsets.only(bottom: 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart, size: 18),
                          SizedBox(width: 6),
                          Text('Statistics', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 18),
                          SizedBox(width: 6),
                          Text('Users', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note, size: 18),
                          SizedBox(width: 6),
                          Text('Hall', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 18),
                          SizedBox(width: 6),
                          Text('Logs', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Content
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: const [
                    StatsTab(),
                    UsersTab(),
                    HallEditTab(),
                    LogsTab(),
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
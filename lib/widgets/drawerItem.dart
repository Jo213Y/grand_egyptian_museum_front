import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../services/api_service.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/halls_screen.dart';
import '../screens/signin_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header ─────────────────────────────
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.black,
              border: Border(
                bottom: BorderSide(color: AppColors.primaryLight, width: 1),
              ),
            ),
            child: Center(
              child: Image.asset(AppAssets.logoGold, width: 90, height: 90),
            ),
          ),

          // ── Items ──────────────────────────────
          if (ApiService.isAdmin)
            _drawerItem(
              context,
              'Dashboard',
              icon: Icons.dashboard,
              onTap: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      (_) => false),
            ),

          _drawerItem(
            context,
            'Home',
            icon: Icons.home,
            onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false),
          ),

          _drawerItem(
            context,
            'Ticket',
            icon: Icons.confirmation_number,
            onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
                    (_) => false),
          ),

          _drawerItem(
            context,
            'Halls',
            icon: Icons.account_balance,
            onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const HallsScreen()),
                    (_) => false),
          ),

          _drawerItem(
            context,
            'About',
            icon: Icons.info,
            onTap: () {},
          ),

          const SizedBox(height: 10),

          _drawerItem(
            context,
            'Logout',
            icon: Icons.logout,
            isDanger: true,
            onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (_) => false),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context,
      String label, {
        required IconData icon,
        VoidCallback? onTap,
        bool isDanger = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: ListTile(
          leading: Icon(icon,
              color: isDanger ? Colors.redAccent : AppColors.gold),
          title: Text(label,
              style: TextStyle(
                  color: isDanger ? Colors.redAccent : AppColors.white,
                  fontWeight: FontWeight.w600)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          hoverColor: AppColors.primary.withOpacity(0.1),
          splashColor: AppColors.primary.withOpacity(0.2),
          onTap: onTap,
        ),
      ),
    );
  }
}
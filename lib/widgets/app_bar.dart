import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';

import '../theme/app_theme.dart';
import '../utils/app_assets.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/halls_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/about_screen.dart';


class GemAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const GemAppBar({
    super.key,
    required this.activePage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  void _go(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 930;

    if (isMobile) {
      return AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.75),
        title: GestureDetector(
          onTap: () => _go(context, const HomeScreen()),
          child: Image.asset(
            AppAssets.logoGold,
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.museum, size: 40, color: AppColors.gold),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      );
    }

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        border: const Border(
          bottom: BorderSide(color: AppColors.primaryLight, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _go(context, const HomeScreen()),
            child: Row(
              children: [
                Image.asset(AppAssets.logoGold, width: 48, height: 48),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grand',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    Text('Egyptian',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    Text('Museum',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          if (ApiService.isAdmin)
            _navItem(
              context,
              'Dashboard',
              Icons.dashboard,
              activePage == 'Dashboard',
                  () => _go(context, const AdminDashboardScreen()),
            ),

          _navItem(
            context,
            'Home',
            Icons.home,
            activePage == 'Home',
                () => _go(context, const HomeScreen()),
          ),

          _navItem(
            context,
            'Ticket',
            Icons.confirmation_number,
            activePage == 'Ticket',
                () => _go(context, const BookingScreen()),
          ),

          _navItem(
            context,
            'Halls',
            Icons.account_balance,
            activePage == 'Halls',
                () => _go(context, const HallsScreen()),
          ),

          _navItem(
            context,
            'About',
            Icons.info,
            activePage == 'About',
                () => _go(context, const AboutScreen()),
          ),

          _navItem(
            context,
            'Logout',
            Icons.logout,
            activePage == 'Logout',
                () => _go(context, const SignInScreen()),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      String label,
      IconData icon,
      bool active,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(color: AppColors.gold, width: 1)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? AppColors.gold : AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: active
                    ? AppTextStyles.navItemActive
                    : AppTextStyles.navItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
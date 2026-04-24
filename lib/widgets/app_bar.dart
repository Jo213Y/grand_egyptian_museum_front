// ── AppBar  ───────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';

import '../theme/app_theme.dart';
import '../utils/app_assets.dart';

class GemAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;
  final VoidCallback? onHome;
  final VoidCallback? onTicket;
  final VoidCallback? onHalls;
  final VoidCallback? onAbout;
  final VoidCallback? onAdmin;
  final VoidCallback? onLogout;

  const GemAppBar({
    super.key,
    required this.activePage,
    this.onHome,
    this.onTicket,
    this.onHalls,
    this.onAbout,
    this.onAdmin,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // أقل من 600px = موبايل

    if (isMobile) {
      // ───────── Mobile AppBar with Drawer ─────────
      return AppBar(
        backgroundColor: Colors.black.withOpacity(0.75),
        title: GestureDetector(
          onTap: onHome ?? () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
          child: Image.asset(
            AppAssets.logoGold,
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => const Icon(Icons.museum, size: 40, color: AppColors.gold),
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

    // ───────── Desktop / Tablet AppBar ─────────
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        border: const Border(bottom: BorderSide(color: AppColors.primaryLight, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        GestureDetector(
          onTap: onHome ?? () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
          child: Row(children: [
            Image.asset(AppAssets.logoGold, width: 48, height: 48),
            const SizedBox(width: 8),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Grand', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w400)),
              Text('Egyptian', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w400)),
              Text('Museum', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w400)),
            ]),
          ]),
        ),
        const Spacer(),
        if (ApiService.isAdmin)
          _navItem(context, 'Admin', activePage == 'Admin', onAdmin ,),
        _navItem(context, 'Home', activePage == 'Home', onHome),
        _navItem(context, 'Ticket', activePage == 'Ticket', onTicket),
        _navItem(context, 'Halls', activePage == 'Halls', onHalls),
        _navItem(context, 'About', activePage == 'About', onAbout),
        _navItem(context, 'Logout', activePage == 'Logout', onLogout),

      ]),
    );
  }



  Widget _navItem(BuildContext ctx, String label, bool active, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Text(label, style: active ? AppTextStyles.navItemActive : AppTextStyles.navItem),
      ),
    );
  }
}
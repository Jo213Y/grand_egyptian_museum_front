import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_assets.dart';
import '../models/hall_model.dart';
import '../services/api_service.dart';
import '../widgets/img_error.dart';
import 'admin/admin_dashboard_screen.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'hall_detail_screen.dart';

class HallsScreen extends StatefulWidget {
  const HallsScreen({super.key});
  @override
  State<HallsScreen> createState() => _HallsScreenState();
}

class _HallsScreenState extends State<HallsScreen> {
  List<HallModel> _halls = [];
  bool _loading = true;
  bool _showPlan = true; // true = show plan, false = show hall cards

  @override
  void initState() {
    super.initState();
    _fetchHalls();
  }

  Future<void> _fetchHalls() async {
    try {
      final halls = await ApiService.getHalls();
      if (mounted) setState(() { _halls = halls; _loading = false; });
    } catch (_) {
      // fallback static
      final halls = HallsData.halls.map((j) => HallModel.fromJson(j)).toList();
      if (mounted) setState(() { _halls = halls; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GemAppBar(
          activePage: 'Halls',
          onAdmin: () =>Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()), (_) => false),
          onHome: () =>Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
          onTicket: () =>Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const BookingScreen()), (_) => false),
          onHalls: () =>Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HallsScreen()), (_) => false),
          onAbout: () =>const {},
          onLogout: () =>Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const SignInScreen()), (_) => false),

        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.black87),
                child: Image.asset(AppAssets.logoGold, width: 80, height: 80),
              ),
              _drawerItem('Home', onTap: () { Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false); }),
              _drawerItem('Ticket', onTap: () { Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const BookingScreen()), (_) => false); }),
              _drawerItem('Halls', onTap: () { Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const HallsScreen()), (_) => false); }),
              _drawerItem('About', onTap: () {}),

              if (ApiService.isAdmin)
                _drawerItem('Admin', onTap: () {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()), (_) => false);
                }),

              _drawerItem('Logout', onTap: () {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()), (_) => false);
              }),
            ],
          ),
        ),
        body: GemBackground(
          imageAsset: AppAssets.bgMuseum,
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: Column(children: [
                      const SizedBox(height: 16),
                      // ── Tab buttons ──────────────────────────
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _tabBtn('Galleries Plan', _showPlan, () => setState(() => _showPlan = true)),
                        const SizedBox(width: 16),
                        _tabBtn('Choose Hall', !_showPlan, () => setState(() => _showPlan = false)),
                      ]),
                      const SizedBox(height: 24),

                      if (_showPlan) _buildPlan() else _buildHallCards(),
                    ]),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.gold,
              fontWeight: FontWeight.bold, fontSize: 16,
            )),
      ),
    );
  }




  // ── Galleries Plan (from Figma — رسمة القاعات) ──────────────
  Widget _buildPlan() {
    return Column(children: [
      const Text('Main Galleries Plan',
          style: TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold,
              fontFamily: 'Inter'),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      // Plan image from Figma
      GemCard(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              AppAssets.hallsPlan,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => GemNetworkImage(
                AppAssets.hallsPlanUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(16),
                // If URL fails too, show a numbered grid
              ),
            ),
          ),
          const SizedBox(height: 16),
          // numbered hall grid below plan (matches Figma grid)
          _buildNumberedGrid(),
          const SizedBox(height: 16),
          // Show details button (Figma)
          GestureDetector(
            onTap: () => setState(() => _showPlan = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: AppDecorations.primaryButton,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Show details',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildNumberedGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (_, i) {
        final n = i + 1;

        // ── تحديد لون كل مجموعة قاعات
        Color bgColor;
        if (n >= 1 && n <= 3) {
          bgColor = Color(0xFFA2AF9B).withOpacity(0.8);
        } else if (n >= 4 && n <= 6) {
          bgColor = Color(0xFFB5C9C8).withOpacity(0.8);
        } else if (n >= 7 && n <= 9) {
          bgColor = Color(0xFFF6CEAA).withOpacity(0.8);
        } else { // 10-12
          bgColor = Color(0xFFF2C3B1).withOpacity(0.8);
        }

        // ── لون الدائرة أغمق شويه
        Color circleColor;
        if (n >= 1 && n <= 3) {
          circleColor = Color(0xFF8A967E);
        } else if (n >= 4 && n <= 6) {
          circleColor = Color(0xFF95B3B1);
        } else if (n >= 7 && n <= 9) {
          circleColor = Color(0xFFD9A880);
        } else {
          circleColor = Color(0xFFD1A293);
        }

        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => HallDetailScreen(hall: _halls[i]))),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bgColor.withOpacity(0.5)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: Center(child: Text('$n',
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ]),
          ),
        );
      },
    );
  }




  // ── Hall Cards (with image + name + description from API) ────
  Widget _buildHallCards() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Choose Hall',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _halls.length,
                itemBuilder: (_, i) => _hallCard(_halls[i]),
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _halls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _hallCard(_halls[i]),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _hallCard(HallModel hall) {
    Color bgColor;
    Color circleColor;
    int n = hall.id;

    if (n >= 1 && n <= 3) {
      bgColor = Color(0xFFA2AF9B).withOpacity(0.8);
      circleColor = Color(0xFF8A967E);
    } else if (n >= 4 && n <= 6) {
      bgColor = Color(0xFFB5C9C8).withOpacity(0.8);
      circleColor = Color(0xFF95B3B1);
    } else if (n >= 7 && n <= 9) {
      bgColor = Color(0xFFF6CEAA).withOpacity(0.8);
      circleColor = Color(0xFFD9A880);
    } else { // 10-12
      bgColor = Color(0xFFF2C3B1).withOpacity(0.8);
      circleColor = Color(0xFFD1A293);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => HallDetailScreen(hall: hall))),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bgColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3),
                blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
          aspectRatio: 16 / 10.5,
          child: Stack(fit: StackFit.expand, children: [
            GemNetworkImage(hall.imageUrl, fit: BoxFit.fill),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: Center(
                  child: Text('${hall.id}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.30, // 25% من ارتفاع الكارت
                widthFactor: 1,
                child: Container(
                  color: bgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          hall.name,
                          style: const TextStyle(
                            color: AppColors.inputFill,
                            fontWeight: FontWeight.bold,
                            height: 0.5,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          hall.shortDescription,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),

        ]),
      ),
    );
  }

  Widget _drawerItem(String label, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.white)),
      onTap: onTap,
    );
  }
}


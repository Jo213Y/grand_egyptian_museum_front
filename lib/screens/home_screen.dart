import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import 'package:grand_egyptian_museum/widgets/drawerItem.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_assets.dart';
import '../services/api_service.dart';
import '../widgets/img_error.dart';
import 'halls_screen.dart';
import 'booking_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goHome(BuildContext ctx) =>
      Navigator.pushAndRemoveUntil(ctx, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  void _goHalls(BuildContext ctx) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const HallsScreen()));
  void _goTicket(BuildContext ctx) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const BookingScreen()));

  Future<void> _openLocation() async {
    final Uri url = Uri.parse(
      'https://maps.app.goo.gl/vPn3nwWhaMcgvAv67',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open map';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // ── Fixed AppBar ────────────────────────────────────────
        appBar: const GemAppBar(activePage: 'Home' ,
        ),
        endDrawer: const AppDrawer(),
        body: GemBackground(
          imageAsset: AppAssets.bgMuseum,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero section ─────────────────────────
                      isWide
                          ? _heroWide(context)
                          : _heroNarrow(context),
                      const SizedBox(height: 30),
                      // ── Info cards ───────────────────────────
                      isWide
                          ? _infoRowWide()
                          : _infoRowNarrow(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero wide (tablet/web) ──────────────────────────────────
  Widget _heroWide(BuildContext ctx) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      // Tutankhamun mask
      Expanded(child: _maskImage(448, 552)),
      const SizedBox(width: 30),
      Expanded(child: _heroText(ctx)),
    ]);
  }

  // ── Hero narrow (phone) ─────────────────────────────────────
  Widget _heroNarrow(BuildContext ctx) {
    return Column(children: [
      _maskImage(double.infinity, 280),
      const SizedBox(height: 24),
      _heroText(ctx),
    ]);
  }
  Widget _maskImage(double w, double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        AppAssets.tutankhamunMask,
        width: w, height: h*1.70, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => GemNetworkImage(
          AppAssets.tutankhamunMaskUrl,
          width: w, height: h, fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  Widget _heroText(BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Welcome to the website to book tickets for the Grand Egyptian Museum',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
            fontFamily: 'Inter', height: 1.4),
      ),
      const SizedBox(height: 16),
      const Text(
        'The Grand Egyptian Museum welcomes you after its full opening, to discover the largest museum in the world dedicated to one civilization.\n\n'
        "Your visit includes King Tutankhamun's halls, the main exhibition halls, the great foyer, the great staircase, the Khufu Boat Museum, the commercial area, and the outdoor gardens, to live an exceptional experience that combines the richness of history and the splendor of contemporary design.",
        style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter', height: 1.65),
      ),
      const SizedBox(height: 28),
      // ── Two CTA buttons ─────────────────────────────────────
      Wrap(spacing: 16, runSpacing: 12, children: [
        _ctaButton('Book Your Visit', () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const BookingScreen()))),
        _ctaButton('Explore Exhibits', () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const HallsScreen()))),
        // ── Admin Dashboard button (only for ADMIN role) ─────────
        if (ApiService.isAdmin) ...[
          GestureDetector(
            onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withOpacity(0.6)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.admin_panel_settings, color: AppColors.white, size: 18),
                SizedBox(width: 8),
                Text('Admin Dashboard',
                    style: TextStyle(color: AppColors.white, fontSize: 16,
                        fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ]),
            ),
          ),
        ],
      ]),

    ]);
  }
  Widget _ctaButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200, height: 50,
        decoration: AppDecorations.primaryButton,
        child: Center(
          child: Text(label, style: AppTextStyles.button.copyWith(fontSize: 18)),
        ),
      ),
    );
  }

  // ── Info cards wide ─────────────────────────────────────────
  Widget _infoRowWide() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _workingHoursCard()),
      const SizedBox(width: 24),
      Expanded(child: _locationCard()),
    ]);
  }
  Widget _infoRowNarrow() {
    return Column(children: [
      _workingHoursCard(),
      const SizedBox(height: 24),
      _locationCard(),
    ]);
  }

  // ── Working Hours card (Figma exact) ────────────────────────
  Widget _workingHoursCard() {
    return const GemCard(
      child: Column(children: [
        Text('Working hours',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                fontFamily: 'Inter'),
            textAlign: TextAlign.center),
        SizedBox(height: 24),
        Text('Daily except Saturdays and Wednesdays',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        SizedBox(height: 8),
        _HoursRow('Museum Complex:', '8:30 am to 7 pm'),
        _HoursRow('Exhibition halls:', '9 am to 6 pm'),
        _HoursRow('Last ticket:', '5 pm'),
        SizedBox(height: 20),
        Text('Saturday and Wednesday',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        SizedBox(height: 8),
        _HoursRow('Museum Complex:', '8:30 am to 10 pm'),
        _HoursRow('Exhibition halls:', '9 am to 9 pm'),
        _HoursRow('Last ticket:', '8 pm'),
      ]),
    );
  }

  // ── Location card with actual GEM map ───────────────────────
  Widget _locationCard() {
    return GemCard(
      child: Column(children: [
        const Text('Location',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                fontFamily: 'Inter'),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        // Actual map from Figma asset (shows GEM location)
        GestureDetector(
          onTap: () => _openLocation(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              AppAssets.mapLocation,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => GemNetworkImage(
                AppAssets.mapLocationUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Address
        const Row(children: [
          Icon(Icons.location_on, color: AppColors.primary, size: 20),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'King Salman Al Ansari Road, Al Remaya, Giza, Egypt\n(Next to the Pyramids of Giza)',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        const Row(children: [
          Icon(Icons.phone, color: AppColors.primary, size: 18),
          SizedBox(width: 6),
          Text('+20 2 3377 8888',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }
}










class _HoursRow extends StatelessWidget {
  final String label;
  final String value;
  const _HoursRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

Widget _drawerItem(String label, {VoidCallback? onTap}) {
  return ListTile(
    title: Text(label, style: const TextStyle(color: AppColors.white)),
    onTap: onTap,
  );
}
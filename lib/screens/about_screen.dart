import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../widgets/app_bar.dart';
import '../widgets/drawerItem.dart';
import '../widgets/common_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLocation() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/vPn3nwWhaMcgvAv67');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open map';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const GemAppBar(activePage: 'About'),
        endDrawer: const AppDrawer(),
        body: GemBackground(
          imageAsset: AppAssets.bgMuseum,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Hero ────────────────────────────────
                      _hero(context),
                      const SizedBox(height: 40),

                      // ── About sections ──────────────────────
                      isWide ? _sectionsWide(context) : _sectionsNarrow(context),
                      const SizedBox(height: 40),

                      // ── Features ────────────────────────────
                      _featuresSection(context),
                      const SizedBox(height: 40),

                      // ── Visit Info ──────────────────────────
                      _visitInfo(context),
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

  // ── Hero ──────────────────────────────────────────────────────
  Widget _hero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.logoGold,
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.museum, size: 80, color: AppColors.gold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Grand Egyptian Museum',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 36,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The World\'s Largest Archaeological Museum',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: AppColors.grayLight,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.gold, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'A monumental tribute to ancient Egyptian civilization, '
                'housing over 100,000 artifacts including the complete treasures '
                'of Tutankhamun — displayed together for the first time in history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.white,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sections Wide ─────────────────────────────────────────────
  Widget _sectionsWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _aboutCard(
          icon: Icons.account_balance,
          title: 'About the Museum',
          body:
          'The Grand Egyptian Museum (GEM) is located near the Giza Pyramids, '
              'the last of the Seven Wonders of the Ancient World. '
              'Spanning over 480,000 square meters, it is the largest '
              'archaeological museum on Earth, dedicated entirely to Egyptian civilization.',
        )),
        const SizedBox(width: 16),
        Expanded(child: _aboutCard(
          icon: Icons.auto_awesome,
          title: 'Our Mission',
          body:
          'To preserve, present, and celebrate Egypt\'s unparalleled cultural '
              'heritage for generations to come. GEM bridges the ancient and modern '
              'world through immersive exhibitions, cutting-edge technology, and '
              'world-class research facilities.',
        )),
      ],
    );
  }

  Widget _sectionsNarrow(BuildContext context) {
    return Column(
      children: [
        _aboutCard(
          icon: Icons.account_balance,
          title: 'About the Museum',
          body:
          'The Grand Egyptian Museum (GEM) is located near the Giza Pyramids, '
              'the last of the Seven Wonders of the Ancient World. '
              'Spanning over 480,000 square meters, it is the largest '
              'archaeological museum on Earth, dedicated entirely to Egyptian civilization.',
        ),
        const SizedBox(height: 16),
        _aboutCard(
          icon: Icons.auto_awesome,
          title: 'Our Mission',
          body:
          'To preserve, present, and celebrate Egypt\'s unparalleled cultural '
              'heritage for generations to come. GEM bridges the ancient and modern '
              'world through immersive exhibitions, cutting-edge technology, and '
              'world-class research facilities.',
        ),
      ],
    );
  }

  Widget _aboutCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.white,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Features / Highlights ─────────────────────────────────────
  Widget _featuresSection(BuildContext context) {
    final features = [
      _Feature(Icons.confirmation_number_outlined, 'Easy Booking',
          'Book your tickets online in minutes and skip the queue.'),
      _Feature(Icons.layers_outlined, '100,000+ Artifacts',
          'Explore the world\'s largest collection of ancient Egyptian artifacts.'),
      _Feature(Icons.king_bed_outlined, 'Tutankhamun Treasures',
          'The complete burial treasures of the Boy King, displayed together for the first time.'),
      _Feature(Icons.translate_outlined, 'Multilingual Guides',
          'Guided tours available in Arabic, English, French, Spanish, and more.'),
      _Feature(Icons.accessible_outlined, 'Fully Accessible',
          'Wheelchair accessible across all floors and exhibitions.'),
      _Feature(Icons.restaurant_outlined, 'Dining & Shopping',
          'World-class restaurants, cafés, and gift shops inside the museum.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What We Offer',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 26,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 50, height: 2, color: AppColors.primary),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (ctx, box) {
          final isWide = box.maxWidth > 600;
          if (isWide) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: features
                  .map((f) => SizedBox(
                width: (box.maxWidth - 16) / 2,
                child: _featureCard(f),
              ))
                  .toList(),
            );
          }
          return Column(
            children: features
                .map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _featureCard(f),
            ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _featureCard(_Feature f) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Icon(f.icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  f.body,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: AppColors.grayLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Visit Info ────────────────────────────────────────────────
  Widget _visitInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Your Visit',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (ctx, box) {
            final isWide = box.maxWidth > 500;
            final items = [
              _InfoRow(Icons.location_on_outlined, 'Location',
                  'Al Remayah Square, Giza, Egypt\n(Next to the Pyramids)'),
              _InfoRow(Icons.access_time_outlined, 'Opening Hours',
                  'Daily: 9:00 AM – 9:00 PM\nLast entry at 8:00 PM'),
              _InfoRow(Icons.phone_outlined, 'Contact',
                  '+20 2 3538 3584\ninfo@gem.gov.eg'),
              _InfoRow(Icons.directions_bus_outlined, 'Getting There',
                  'Bus, taxi, or private car.\nMetro to Giza station + taxi.'),
            ];
            if (isWide) {
              return Wrap(
                spacing: 24,
                runSpacing: 20,
                children: items
                    .map((i) => SizedBox(width: (box.maxWidth - 24) / 2, child: _infoRowWidget(i)))
                    .toList(),
              );
            }
            return Column(
              children: items
                  .map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _infoRowWidget(i),
              ))
                  .toList(),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openLocation,
              icon: const Icon(Icons.map_outlined),
              label: const Text('View on Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWidget(_InfoRow r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(r.icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r.value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: AppColors.white,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(this.icon, this.title, this.body);
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
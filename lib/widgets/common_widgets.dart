import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/screens/signin_screen.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../services/api_service.dart';
import '../screens/admin/admin_dashboard_screen.dart';

// ── Background  ───────────────────────
class GemBackground extends StatelessWidget {
  final Widget child;
  final String? imageAsset;
  const GemBackground({super.key, required this.child, this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      _buildBg(),
      // dark gradient overlay (Figma: rgba(0,0,0,0) → black)
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
            stops: [0.3, 1.0],
          ),
        ),
      ),
      child,
    ]);
  }

  Widget _buildBg() {
    final asset = imageAsset ?? AppAssets.bgMuseum;
    return Image.asset(asset, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.network(
              AppAssets.bgMuseumUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A0E05)),
            ));
  }
}

// ── Card decoration ─────────────────────────────────────
class GemCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GemCard({super.key, required this.child, this.padding, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: AppDecorations.card,
      child: child,
    );
  }
}










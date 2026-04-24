// ── Responsive network image with local fallback ─────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GemNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const GemNetworkImage(this.url,
      {super.key,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
        this.borderRadius});

  @override
  Widget build(BuildContext context) {
    Widget img = Image.network(url,
        width: width, height: height, fit: fit,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
            width: width, height: height,
            color: AppColors.primaryCard,
            child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))),
        errorBuilder: (_, __, ___) => Container(
            width: width, height: height,
            color: AppColors.primaryCard,
            child: const Center(
                child: Icon(Icons.image_not_supported, color: AppColors.gold, size: 40))));

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
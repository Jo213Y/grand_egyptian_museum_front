// ── Step indicator  ─────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StepCircle extends StatelessWidget {
  final int number;
  final bool active;
  const StepCircle({super.key, required this.number, required this.active});

  @override
  Widget build(BuildContext context) => Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      color: active ? AppColors.primary : AppColors.primaryLight.withOpacity(0.35),
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.primaryLight, width: 1.5),
    ),
    child: Center(
      child: Text('$number',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
    ),
  );
}
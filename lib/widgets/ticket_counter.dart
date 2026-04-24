// ── Ticket counter row ────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TicketCounter extends StatelessWidget {
  final String title;
  final String ageRange;
  final String description;
  final String price;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const TicketCounter({
    super.key,
    required this.title,
    required this.ageRange,
    this.description = '',
    required this.price,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.access_time, size: 12, color: AppColors.black),
                const SizedBox(width: 4),
                Text(ageRange,
                    style: const TextStyle(fontSize: 12, color: AppColors.black)),
              ]),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
              const SizedBox(height: 4),
              Text(price, style: AppTextStyles.price),
            ],
          ),
        ),
        _Btn(Icons.remove, onDecrement, false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        _Btn(Icons.add, onIncrement, true),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _Btn(this.icon, this.onTap, this.filled);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          color: filled ? Colors.white : AppColors.gray, size: 18),
    ),
  );
}
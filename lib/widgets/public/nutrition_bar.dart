import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class NutritionBar extends StatelessWidget {
  const NutritionBar({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.color,
    required this.progress,
  });

  final String label;
  final String valueLabel;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                color: AppColors.slate700,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

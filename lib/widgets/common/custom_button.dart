import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.emerald,
    this.foregroundColor = AppColors.white,
    this.borderColor,
    this.expanded = false,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool expanded;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final Widget button = isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              side: BorderSide(color: borderColor ?? AppColors.slate300),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.slate800 : AppColors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark ? const Color(0x28000000) : const Color(0x140F172A),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

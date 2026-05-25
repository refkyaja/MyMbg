import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../common/section_card.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trailing,
    this.valueFontSize,
    this.trailingFontSize,
    this.trailingColor,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final String? trailing;
  final double? valueFontSize;
  final double? trailingFontSize;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        value,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.slate900,
                          fontSize: valueFontSize ?? 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (trailing != null) ...<Widget>[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            trailing!,
                            style: TextStyle(
                              color: trailingColor ??
                                  (isDark
                                      ? AppColors.slate400
                                      : AppColors.slate500),
                              fontSize: trailingFontSize ?? 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

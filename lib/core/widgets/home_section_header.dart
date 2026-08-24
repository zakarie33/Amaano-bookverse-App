import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Section title row: uppercase label + chevron.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.titleColor,
  });

  final String title;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sectionTitle.copyWith(
                    color: titleColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

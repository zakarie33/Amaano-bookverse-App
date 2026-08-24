import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Star rating row with numeric score and review count.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.compact = false,
    this.lightOnDark = false,
  });

  final double rating;
  final int reviewCount;
  final bool compact;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    final starSize = compact ? 12.0 : 14.0;
    final fontSize = compact ? 10.0 : 11.0;
    final hasRating = rating > 0;

    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = rating > i;
          final half = rating > i && rating < i + 1;
          return Icon(
            half ? Icons.star_half_rounded : Icons.star_rounded,
            size: starSize,
            color: filled || half
                ? AppColors.caramel
                : (lightOnDark
                    ? AppColors.espressoSoft.withValues(alpha: 0.8)
                    : AppColors.tortillaAlt),
          );
        }),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            hasRating
                ? '${rating.toStringAsFixed(1)}${reviewCount > 0 ? ' ($reviewCount)' : ''}'
                : (reviewCount > 0 ? '$reviewCount reviews' : 'New'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: lightOnDark
                  ? AppColors.muted.withValues(alpha: 0.95)
                  : AppColors.textOnCardMuted,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

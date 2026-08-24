import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'peek_content_carousel.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = PeekContentCarousel.cardWidthFor(context);
    final cardHeight = PeekContentCarousel.carouselHeightFor(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _Bar(width: 200, height: 28),
        const SizedBox(height: 8),
        _Bar(width: 180, height: 16),
        const SizedBox(height: 20),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, _) => _Bar(width: 72, height: 36, radius: 18),
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < 3; i++) ...[
          _Bar(width: 140, height: 16),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, _) =>
                  _Bar(width: cardWidth, height: cardHeight, radius: 14),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    this.width,
    required this.height,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

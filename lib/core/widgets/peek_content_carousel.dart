import 'package:flutter/material.dart';

import '../../features/books/models/content_model.dart';
import 'book_card.dart';

/// Horizontal carousel — ~2.5 reference-style cards visible.
class PeekContentCarousel extends StatelessWidget {
  const PeekContentCarousel({
    super.key,
    required this.items,
    required this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final List<ContentModel> items;
  final void Function(ContentModel item) onTap;
  final void Function(ContentModel item)? onAction;
  final String? actionLabel;

  static double cardWidthFor(BuildContext context) =>
      BookCard.carouselWidthFor(context);

  static double carouselHeightFor(BuildContext context) =>
      BookCard.carouselHeightForWidth(cardWidthFor(context));

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final cardWidth = cardWidthFor(context);
    final carouselHeight = carouselHeightFor(context);

    return SizedBox(
      height: carouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return BookCard(
            width: cardWidth,
            item: item,
            actionLabel: actionLabel,
            onTap: () => onTap(item),
            onAction: onAction == null ? null : () => onAction!(item),
          );
        },
      ),
    );
  }
}

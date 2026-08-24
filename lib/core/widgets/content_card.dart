import 'package:flutter/material.dart';

import '../../features/books/models/content_model.dart';
import 'book_card.dart';

/// Book/audiobook card — delegates to reference-style [BookCard].
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAction,
    this.compact = false,
    this.carousel = false,
    this.width,
    this.actionLabel,
  });

  final ContentModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool compact;
  final bool carousel;
  final double? width;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final layout = compact
        ? BookCardLayout.compact
        : (carousel ? BookCardLayout.carousel : BookCardLayout.grid);

    return BookCard(
      item: item,
      width: width ?? (carousel ? BookCard.carouselWidthFor(context) : null),
      layout: layout,
      onTap: onTap,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

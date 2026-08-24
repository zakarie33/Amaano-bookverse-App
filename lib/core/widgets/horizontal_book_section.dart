import 'package:flutter/material.dart';

import '../../features/books/models/content_model.dart';
import 'home_section_header.dart';
import 'peek_content_carousel.dart';

/// Horizontal scrolling row of [ContentCard] carousel cards.
class HorizontalBookSection extends StatelessWidget {
  const HorizontalBookSection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.onItemAction,
    this.actionLabel,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 0),
  });

  final String title;
  final List<ContentModel> items;
  final void Function(ContentModel item) onItemTap;
  final void Function(ContentModel item)? onItemAction;
  final String? actionLabel;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, onTap: onSeeAll),
          const SizedBox(height: 12),
          PeekContentCarousel(
            items: items,
            actionLabel: actionLabel,
            onTap: onItemTap,
            onAction: onItemAction,
          ),
        ],
      ),
    );
  }
}

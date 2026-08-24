import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../features/books/models/content_model.dart';
import 'home_section_header.dart';

/// Vertical ranked bestseller section.
class BestsellersRankedSection extends StatelessWidget {
  const BestsellersRankedSection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 0),
  });

  final String title;
  final List<ContentModel> items;
  final void Function(ContentModel item) onItemTap;
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
          const SizedBox(height: 4),
          ...List.generate(items.length.clamp(0, 5), (index) {
            final item = items[index];
            return BestsellerListItem(
              rank: index + 1,
              item: item,
              onTap: () => onItemTap(item),
            );
          }),
        ],
      ),
    );
  }
}

/// Vertical ranked bestseller row — matches reference list layout.
class BestsellerListItem extends StatefulWidget {
  const BestsellerListItem({
    super.key,
    required this.rank,
    required this.item,
    this.onTap,
  });

  final int rank;
  final ContentModel item;
  final VoidCallback? onTap;

  @override
  State<BestsellerListItem> createState() => _BestsellerListItemState();
}

class _BestsellerListItemState extends State<BestsellerListItem> {
  double _scale = 1;

  String get _priceLabel {
    if (widget.item.isFreeContent) return 'Free';
    if (widget.item.price != null && widget.item.price! > 0) {
      return NumberFormat.simpleCurrency().format(widget.item.price);
    }
    return 'Paid';
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.item.author?.trim();

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${widget.rank}',
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionTitle.copyWith(
                    fontSize: 18,
                    color: AppColors.gold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 68,
                  child: _Thumbnail(item: widget.item),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bookTitleCompact,
                    ),
                    if (author != null && author.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.author,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _priceLabel,
                style: AppTypography.price,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final ContentModel item;

  @override
  Widget build(BuildContext context) {
    final url = item.coverUrl;
    return ColoredBox(
      color: AppColors.surface,
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 280),
              placeholder: (_, _) => const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, _, _) => const Icon(
                Icons.menu_book_rounded,
                color: AppColors.chipInactive,
                size: 22,
              ),
            )
          : const Icon(
              Icons.menu_book_rounded,
              color: AppColors.chipInactive,
              size: 22,
            ),
    );
  }
}

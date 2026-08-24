import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../../features/books/models/content_model.dart';

enum BookCardLayout { carousel, compact, grid }

/// Reference-style book card — cover-first, title, author, rating, price, action icon.
class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.item,
    this.width,
    this.layout = BookCardLayout.carousel,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final ContentModel item;
  final double? width;
  final BookCardLayout layout;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  static const double _coverRadius = 14;
  static const double _coverAspectRatio = 0.68;
  static const double _bottomSectionHeight = 84;

  static double carouselWidthFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.36;

  static double carouselHeightForWidth(double cardWidth) =>
      cardWidth / _coverAspectRatio + 8 + _bottomSectionHeight;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  double _scale = 1;

  String get _priceLabel {
    if (widget.item.isFreeContent) return 'Free';
    if (widget.item.price != null && widget.item.price! > 0) {
      return NumberFormat.simpleCurrency().format(widget.item.price);
    }
    return 'Paid';
  }

  bool get _isAudioContent {
    final label = (widget.actionLabel ?? '').toLowerCase();
    if (label.contains('play') || label.contains('listen')) return true;
    return widget.item.canListen && !widget.item.canRead;
  }

  IconData get _freeActionIcon =>
      _isAudioContent ? Icons.play_arrow_rounded : Icons.menu_book_rounded;

  String? get _authorLine {
    final author = widget.item.author?.trim();
    if (author != null && author.isNotEmpty) return author;
    final category = widget.item.category?.trim();
    if (category != null && category.isNotEmpty) return category;
    return null;
  }

  double get _ratingValue => widget.item.rating ?? 0;

  void _setPressed(bool pressed) {
    if (!mounted) return;
    setState(() => _scale = pressed ? 0.96 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.layout) {
      BookCardLayout.compact => _buildCompactCard(context),
      BookCardLayout.grid => _buildCarouselCard(context),
      BookCardLayout.carousel => _buildCarouselCard(context),
    };
  }

  Widget _buildCarouselCard(BuildContext context) {
    final cardWidth = widget.width ?? BookCard.carouselWidthFor(context);

    return SizedBox(
      width: cardWidth,
      child: _animatedShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: BookCard._coverAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BookCard._coverRadius),
                child: _CoverImage(item: widget.item),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: BookCard._bottomSectionHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.18,
                    ),
                  ),
                  if (_authorLine != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _authorLine!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildFooterRow(compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return _animatedShell(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 84,
                height: 112,
                child: _CoverImage(item: widget.item),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.22,
                      ),
                    ),
                    if (_authorLine != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _authorLine!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _buildFooterRow(compact: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow({required bool compact}) {
    final ratingText =
        _ratingValue > 0 ? _ratingValue.toStringAsFixed(1) : 'New';
    final priceSize = compact ? 11.5 : 13.0;
    final showAction = widget.onAction != null || widget.onTap != null;

    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          size: 14,
          color: AppColors.starGold,
        ),
        const SizedBox(width: 2),
        Text(
          ratingText,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            _priceLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: priceSize,
            ),
          ),
        ),
        if (showAction) ...[
          const SizedBox(width: 6),
          _ActionIconButton(
            icon: widget.item.isFreeContent
                ? _freeActionIcon
                : Icons.add_shopping_cart_rounded,
            onPressed: widget.onAction ?? widget.onTap,
          ),
        ],
      ],
    );
  }

  Widget _animatedShell({required Widget child}) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: ClipRect(
        child: AnimatedScale(
          scale: _scale,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: child,
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

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
              fadeInDuration: const Duration(milliseconds: 320),
              fadeOutDuration: const Duration(milliseconds: 120),
              placeholder: (_, _) => const _CoverPlaceholder(),
              errorWidget: (_, _, _) =>
                  _CoverPlaceholder(isAudio: item.hasAudio),
            )
          : _CoverPlaceholder(isAudio: item.hasAudio),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({this.isAudio = false});

  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        isAudio ? Icons.headphones_rounded : Icons.menu_book_rounded,
        color: AppColors.espressoSoft.withValues(alpha: 0.4),
        size: 32,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryBrown,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../features/books/models/content_model.dart';
import 'home_section_header.dart';

class AuthorSummary {
  const AuthorSummary({
    required this.name,
    required this.books,
  });

  final String name;
  final List<ContentModel> books;

  String? get coverUrl {
    for (final book in books) {
      final url = book.coverUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  int get bookCount => books.length;
}

/// Circular author portrait — reference-style, no card box.
class FeaturedAuthorCard extends StatefulWidget {
  const FeaturedAuthorCard({
    super.key,
    required this.author,
    this.onTap,
  });

  final AuthorSummary author;
  final VoidCallback? onTap;

  static double widthFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.28;

  @override
  State<FeaturedAuthorCard> createState() => _FeaturedAuthorCardState();
}

class _FeaturedAuthorCardState extends State<FeaturedAuthorCard> {
  double _scale = 1;

  String get _initials {
    final parts = widget.author.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final width = FeaturedAuthorCard.widthFor(context);
    final cover = widget.author.coverUrl;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.tortillaAlt,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: cover != null
                        ? CachedNetworkImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 320),
                            placeholder: (_, _) => _avatarFallback(),
                            errorWidget: (_, _, _) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: Text(
                  widget.author.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bookTitleCompact.copyWith(
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return ColoredBox(
      color: AppColors.tortillaAlt,
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.bookTitle.copyWith(
            color: AppColors.primaryBrown,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of [FeaturedAuthorCard]s.
class FeaturedAuthorsSection extends StatelessWidget {
  const FeaturedAuthorsSection({
    super.key,
    required this.title,
    required this.authors,
    required this.onAuthorTap,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 0),
  });

  final String title;
  final List<AuthorSummary> authors;
  final void Function(AuthorSummary author) onAuthorTap;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, onTap: onSeeAll),
          const SizedBox(height: 14),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: authors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final author = authors[index];
                return FeaturedAuthorCard(
                  author: author,
                  onTap: () => onAuthorTap(author),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

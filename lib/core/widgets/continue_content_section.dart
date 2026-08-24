import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../features/books/models/content_model.dart';

/// Cover-only continue reading / listening row for the home feed.
class ContinueContentSection extends StatelessWidget {
  const ContinueContentSection({
    super.key,
    this.reading,
    this.listening,
    this.onReading,
    this.onListening,
  });

  final ContentModel? reading;
  final ContentModel? listening;
  final VoidCallback? onReading;
  final VoidCallback? onListening;

  @override
  Widget build(BuildContext context) {
    if (reading == null && listening == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          if (reading != null)
            Expanded(
              child: _ContinueTile(
                label: 'Continue reading',
                item: reading!,
                icon: Icons.menu_book_rounded,
                onTap: onReading,
              ),
            ),
          if (reading != null && listening != null) const SizedBox(width: 12),
          if (listening != null)
            Expanded(
              child: _ContinueTile(
                label: 'Continue listening',
                item: listening!,
                icon: Icons.headphones_rounded,
                onTap: onListening,
              ),
            ),
        ],
      ),
    );
  }
}

class _ContinueTile extends StatelessWidget {
  const _ContinueTile({
    required this.label,
    required this.item,
    required this.icon,
    this.onTap,
  });

  final String label;
  final ContentModel item;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.espressoSoft.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.caramel),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.tortilla,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 0.72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _cover(item.coverUrl),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.tortillaAlt),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.tortillaAlt,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.espressoSoft),
    );
  }
}

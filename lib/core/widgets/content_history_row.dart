import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../features/books/models/content_model.dart';

/// Compact cover strip for read/listen history on home.
class ContentHistoryRow extends StatelessWidget {
  const ContentHistoryRow({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<ContentModel> items;
  final void Function(ContentModel item) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.tortilla,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => onTap(item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 82,
                    child: _cover(item.coverUrl),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cover(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.espressoSoft),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.espressoSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, color: AppColors.caramel),
    );
  }
}

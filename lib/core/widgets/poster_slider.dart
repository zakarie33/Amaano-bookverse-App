import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../features/home/models/announcement_model.dart';

/// Auto-advancing poster carousel from admin announcements.
class PosterSlider extends StatefulWidget {
  const PosterSlider({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<AnnouncementModel> items;
  final void Function(AnnouncementModel item)? onTap;

  @override
  State<PosterSlider> createState() => _PosterSliderState();
}

class _PosterSliderState extends State<PosterSlider> {
  final _pageController = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _next());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (!mounted || widget.items.length < 2) return;
    final next = (_index + 1) % widget.items.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => widget.onTap?.call(item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item.posterUrl != null && item.posterUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: item.posterUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.espressoSoft,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.caramel,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _textFallback(item),
                          )
                        else
                          _textFallback(item),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.espressoDeep.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.tortilla,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (item.teaser != null &&
                                  item.teaser!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.teaser!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.mutedText
                                        .withValues(alpha: 0.95),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppColors.caramel : AppColors.espressoSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _textFallback(AnnouncementModel item) {
    return Container(
      color: AppColors.espressoSoft,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: Text(
        item.title,
        style: const TextStyle(
          color: AppColors.tortilla,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

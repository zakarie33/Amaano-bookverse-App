import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum CarvedBottomNavStyle {
  /// Deep brown bar — Home tab only.
  home,
  /// White bar — Books, Audio, and Profile tabs.
  light,
}

class CarvedBottomNav extends StatelessWidget {
  const CarvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.style = CarvedBottomNavStyle.home,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final CarvedBottomNavStyle style;

  static const _barHeight = 68.0;
  static const _cornerRatio = 0.2;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'Books'),
    (Icons.headphones_outlined, Icons.headphones_rounded, 'Audio'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  bool get _isLight => style == CarvedBottomNavStyle.light;

  Color get _backgroundColor =>
      _isLight ? AppColors.navLightBackground : AppColors.navBackground;

  Color get _selectedColor =>
      _isLight ? AppColors.navLightSelected : AppColors.navSelected;

  Color get _unselectedColor =>
      _isLight ? AppColors.navLightUnselected : AppColors.navUnselected;

  @override
  Widget build(BuildContext context) {
    final radius = _barHeight * _cornerRatio;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? 8 : 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: _backgroundColor,
          border: _isLight
              ? Border.all(
                  color: AppColors.chipInactive.withValues(alpha: 0.22),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(
                alpha: _isLight ? 0.1 : 0.18,
              ),
              blurRadius: _isLight ? 16 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: _barHeight,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = currentIndex == index;
              return Expanded(
                child: _NavItem(
                  label: item.$3,
                  icon: selected ? item.$2 : item.$1,
                  selected: selected,
                  selectedColor: _selectedColor,
                  unselectedColor: _unselectedColor,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconBox = selected ? 36.0 : 32.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.gold.withValues(alpha: 0.15),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.gold.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: selected ? 22 : 20,
                  color: selected ? selectedColor : unselectedColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navLabel.copyWith(
                  color: selected ? selectedColor : unselectedColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

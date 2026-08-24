import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/auth_service.dart';
import '../utils/auth_guard.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/notifications/notification_provider.dart';
import 'cart_bottom_sheet.dart';
import 'notification_panel.dart';
import 'sidebar_toggle_button.dart';

/// Top app bar: menu, optional title, search, cart, notification bell.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    this.title,
    this.onSearch,
    this.useLightSurface = true,
  });

  final String? title;
  final VoidCallback? onSearch;
  final bool useLightSurface;

  Color get _iconColor => AppColors.textPrimary;

  Color get _buttonBg => AppColors.surface;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final cartCount = context.watch<CartProvider>().itemCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const SidebarToggleButton(),
          if (title != null) ...[
            const SizedBox(width: 10),
            Expanded(child: Text(title!, style: AppTypography.appTitle)),
          ] else ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.chipInactive.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.primaryBrown,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Amaano BookVerse',
                style: AppTypography.appTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          IconButton(
            onPressed: onSearch == null
                ? null
                : () => requireLogin(context, onSearch!),
            icon: Icon(Icons.search_rounded, color: _iconColor),
            tooltip: 'Search',
            style: IconButton.styleFrom(backgroundColor: _buttonBg),
          ),
          const SizedBox(width: 4),
          Material(
            color: _buttonBg,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => requireLogin(context, () => showCartBottomSheet(context)),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(
                    cartCount > 99 ? '99+' : '$cartCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: AppColors.gold,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: _iconColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          if (auth.isLoggedIn) ...[
            const SizedBox(width: 6),
            const NotificationBellButton(),
          ],
        ],
      ),
    );
  }
}

class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removePanel();
    super.dispose();
  }

  void _removePanel() {
    _entry?.remove();
    _entry = null;
  }

  void _togglePanel() {
    if (_entry != null) {
      _removePanel();
      return;
    }

    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      context.read<NotificationProvider>().refresh(alertNew: false);
    }

    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = box?.size ?? Size.zero;
    final screenWidth = MediaQuery.sizeOf(context).width;
    const panelWidth = 340.0;
    var left = offset.dx + size.width - panelWidth;
    if (left < 12) left = 12;
    if (left + panelWidth > screenWidth - 12) {
      left = screenWidth - panelWidth - 12;
    }

    _entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removePanel,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            left: left,
            child: NotificationPanel(onClose: _removePanel),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    final unread = context.watch<NotificationProvider>().unreadCount;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _togglePanel,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Badge(
            isLabelVisible: unread > 0,
            label: Text(
              unread > 99 ? '99+' : '$unread',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.error,
            child: Icon(
              unread > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              color: unread > 0 ? AppColors.gold : AppColors.textPrimary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/library/screens/my_purchases_screen.dart';
import '../../features/notifications/notification_provider.dart';
import '../../features/notifications/screens/notifications_screen.dart';

/// Dropdown-style notification panel (does not navigate away immediately).
class NotificationPanel extends StatelessWidget {
  const NotificationPanel({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'approval':
        return Icons.check_circle_outline;
      case 'rejection':
        return Icons.cancel_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  void _openPurchases(BuildContext context) {
    onClose();
    Navigator.of(context).pushNamed(MyPurchasesScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final provider = context.watch<NotificationProvider>();
    final unread = provider.unreadCount;
    final items = provider.items;

    return Material(
      elevation: 12,
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              color: AppColors.espresso,
              child: Row(
                children: [
                  const Icon(Icons.notifications_rounded,
                      color: AppColors.caramel, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      unread > 0 ? 'Notifications ($unread)' : 'Notifications',
                      style: const TextStyle(
                        color: AppColors.tortilla,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (auth.isLoggedIn && unread > 0)
                    TextButton(
                      onPressed: provider.markAllRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: AppColors.caramel,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.mutedText, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            if (!auth.isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Sign in to see announcements and payment updates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textOnCardMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        onClose();
                        Navigator.of(context)
                            .pushNamed(LoginScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramel,
                        foregroundColor: AppColors.espressoDeep,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              )
            else if (provider.loading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(color: AppColors.caramel),
              )
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No notifications yet',
                  style: TextStyle(color: AppColors.textOnCardMuted),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length.clamp(0, 8),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = items[index];
                    return _NotificationRow(
                      item: n,
                      icon: _iconForType(n.type),
                      onTap: () {
                        provider.markRead(n);
                        final link = n.link?.toLowerCase() ?? '';
                        if (link.contains('purchase') || link.contains('order')) {
                          _openPurchases(context);
                        }
                      },
                    );
                  },
                ),
              ),
            if (auth.isLoggedIn && items.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.tortillaAlt.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await provider.markAllRead();
                        onClose();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.textOnCardMuted),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        onClose();
                        Navigator.of(context)
                            .pushNamed(NotificationsScreen.routeName);
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.item,
    required this.icon,
    required this.onTap,
  });

  final NotificationModel item;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.espressoSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: AppColors.espresso,
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.caramel,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textOnCardMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

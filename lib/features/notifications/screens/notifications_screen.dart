import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/widgets/loading_view.dart';
import '../../library/screens/my_purchases_screen.dart';
import '../notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh(alertNew: false);
    });
  }

  IconData _iconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'approval':
        return Icons.check_circle_outline;
      case 'rejection':
        return Icons.cancel_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'order':
      case 'payment':
        return Icons.receipt_long_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  void _openNotification(NotificationModel n) {
    context.read<NotificationProvider>().markRead(n);
    final link = n.link?.toLowerCase() ?? '';
    if (link.contains('purchase') || link.contains('order')) {
      Navigator.of(context).pushNamed(MyPurchasesScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    final unread = provider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.espresso,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.espressoDeep,
        foregroundColor: AppColors.tortilla,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: provider.markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: provider.loading && items.isEmpty
          ? const LoadingView()
          : items.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet\nAdmin announcements and payment updates will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedText, height: 1.5),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.refresh(alertNew: false),
                  color: AppColors.caramel,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return Material(
                        color: n.isRead
                            ? AppColors.cream.withValues(alpha: 0.85)
                            : AppColors.cream,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _openNotification(n),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.caramel
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconForType(n.type),
                                    color: AppColors.espresso,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: TextStyle(
                                                color: AppColors.espresso,
                                                fontWeight: n.isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (!n.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.caramel,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        n.message,
                                        style: const TextStyle(
                                          color: AppColors.mutedText,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (n.createdAt != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          n.createdAt!,
                                          style: const TextStyle(
                                            color: AppColors.mutedText,
                                            fontSize: 11,
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
    );
  }
}

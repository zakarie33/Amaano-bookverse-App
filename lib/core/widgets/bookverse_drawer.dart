import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../utils/auth_guard.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/library/screens/my_library_screen.dart';
import '../../features/library/screens/my_purchases_screen.dart';
import '../../features/notifications/notification_provider.dart';
import '../../features/notifications/screens/notifications_screen.dart';

/// BookVerse slide-out sidebar menu.
class BookVerseDrawer extends StatelessWidget {
  const BookVerseDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  void _closeAnd(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final user = auth.user;

    return Drawer(
      backgroundColor: AppColors.espressoDeep,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.espresso,
                    AppColors.espressoSoft.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.caramel,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'BookVerse',
                          style: TextStyle(
                            color: AppColors.tortilla,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.isLoggedIn
                        ? 'Hello, ${user?.name ?? 'Reader'}'
                        : 'Browse as guest',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _sectionLabel('Browse'),
                  _DrawerTile(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: currentIndex == 0,
                    onTap: () => _closeAnd(context, () => onSelectTab(0)),
                  ),
                  _DrawerTile(
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book_rounded,
                    label: 'Books',
                    selected: currentIndex == 1,
                    onTap: () => _closeAnd(context, () => onSelectTab(1)),
                  ),
                  _DrawerTile(
                    icon: Icons.headphones_outlined,
                    selectedIcon: Icons.headphones_rounded,
                    label: 'Audiobooks',
                    selected: currentIndex == 2,
                    onTap: () => _closeAnd(context, () => onSelectTab(2)),
                  ),
                  _DrawerTile(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                    selected: currentIndex == 3,
                    onTap: () => _closeAnd(context, () => onSelectTab(3)),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Divider(color: AppColors.espressoSoft, height: 1),
                  ),
                  _sectionLabel('Account'),
                  _DrawerTile(
                    icon: Icons.collections_bookmark_outlined,
                    label: 'My Library',
                    onTap: () => _closeAnd(context, () {
                      requireLogin(context, () {
                        Navigator.of(context)
                            .pushNamed(MyLibraryScreen.routeName);
                      });
                    }),
                  ),
                  _DrawerTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Purchases',
                    onTap: () => _closeAnd(context, () {
                      requireLogin(context, () {
                        Navigator.of(context)
                            .pushNamed(MyPurchasesScreen.routeName);
                      });
                    }),
                  ),
                  _DrawerTile(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Cart',
                    onTap: () => _closeAnd(context, () {
                      requireLogin(context, () {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      });
                    }),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    badge: unread > 0 ? (unread > 99 ? '99+' : '$unread') : null,
                    onTap: () => _closeAnd(context, () {
                      requireLogin(context, () {
                        Navigator.of(context)
                            .pushNamed(NotificationsScreen.routeName);
                      });
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: auth.isLoggedIn
                  ? OutlinedButton.icon(
                      onPressed: () => _closeAnd(context, () async {
                        await auth.logout();
                      }),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tortilla,
                        side: const BorderSide(color: AppColors.espressoSoft),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _closeAnd(context, () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      }),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramel,
                        foregroundColor: AppColors.espressoDeep,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.caramelDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedIcon,
    this.selected = false,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? AppColors.caramel.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(
            selected ? (selectedIcon ?? icon) : icon,
            color: selected ? AppColors.caramel : AppColors.mutedText,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.tortilla : AppColors.mutedText,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          trailing: badge != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.caramel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.espressoDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

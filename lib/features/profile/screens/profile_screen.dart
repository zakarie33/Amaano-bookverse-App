import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../library/screens/my_library_screen.dart';
import '../../library/screens/my_purchases_screen.dart';
import '../../notifications/notification_provider.dart';
import '../../notifications/screens/notifications_screen.dart';
import 'profile_activities_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) return;
    setState(() => _loading = true);
    try {
      final api = ApiService();
      final data = await api.get(ApiConstants.profile);
      if (!mounted) return;
      final user = data is Map ? data['user'] ?? data['profile'] : null;
      setState(() {
        _profile = user is Map ? Map<String, dynamic>.from(user) : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final embedded = widget.embeddedInShell;

    if (!auth.isLoggedIn) {
      return Container(
        color: AppColors.espresso,
        child: embedded
            ? _buildGuestProfile(context)
            : SafeArea(child: _buildGuestProfile(context)),
      );
    }

    final user = auth.user!;
    final name = _profile?['name']?.toString() ?? user.name;
    final email = _profile?['email']?.toString() ?? user.email;
    final phone = _profile?['phone']?.toString();
    final academic = _profile?['academic_level']?.toString();

    final profileBody = _loading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.caramel),
          )
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.caramel.withValues(alpha: 0.35),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.espresso,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.tortilla,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(email, style: const TextStyle(color: AppColors.mutedText)),
              if (phone != null && phone.isNotEmpty)
                Text(phone, style: const TextStyle(color: AppColors.mutedText)),
              if (academic != null && academic.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  academic,
                  style: const TextStyle(
                    color: AppColors.caramel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _dashCard(
                context,
                'My Library',
                Icons.collections_bookmark_rounded,
                () => Navigator.of(context).pushNamed(MyLibraryScreen.routeName),
              ),
              _dashCard(
                context,
                'My Purchases',
                Icons.receipt_long_outlined,
                () => Navigator.of(context).pushNamed(MyPurchasesScreen.routeName),
              ),
              _dashCard(
                context,
                'Cart',
                Icons.shopping_cart_outlined,
                () => Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
              _dashCard(
                context,
                'Notifications',
                Icons.notifications_outlined,
                () => Navigator.of(context)
                    .pushNamed(NotificationsScreen.routeName),
                badgeCount: context.watch<NotificationProvider>().unreadCount,
              ),
              _dashCard(
                context,
                'Activities',
                Icons.history_rounded,
                () => Navigator.of(context)
                    .pushNamed(ProfileActivitiesScreen.routeName),
              ),
              _dashCard(
                context,
                'Account Settings',
                Icons.settings_outlined,
                () => requireLogin(context, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account settings coming soon')),
                  );
                }),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Sign out',
                outlined: true,
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      HomeScreen.routeName,
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );

    return Container(
      color: AppColors.espresso,
      child: embedded ? profileBody : SafeArea(child: profileBody),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.caramel.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 56,
              color: AppColors.caramel,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your BookVerse profile',
            style: TextStyle(
              color: AppColors.tortilla,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to view your dashboard, library, and purchases.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText, height: 1.45),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Login',
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Create Account',
            outlined: true,
            onPressed: () =>
                Navigator.of(context).pushNamed(RegisterScreen.routeName),
          ),
          ],
        ),
      ),
    );
  }

  Widget _dashCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    return Card(
      color: AppColors.espressoSoft.withValues(alpha: 0.4),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.caramel),
        title: Text(title, style: const TextStyle(color: AppColors.tortilla)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.caramel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: AppColors.espressoDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

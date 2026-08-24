import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../../features/notifications/notification_provider.dart';

/// Starts/stops notification polling when auth state or app lifecycle changes.
class NotificationAuthBridge extends StatefulWidget {
  const NotificationAuthBridge({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationAuthBridge> createState() => _NotificationAuthBridgeState();
}

class _NotificationAuthBridgeState extends State<NotificationAuthBridge>
    with WidgetsBindingObserver {
  AuthService? _auth;
  String? _activeUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthService>();
    if (!identical(_auth, auth)) {
      _auth?.removeListener(_sync);
      _auth = auth;
      _auth!.addListener(_sync);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _auth?.removeListener(_sync);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfLoggedIn();
    }
  }

  void _refreshIfLoggedIn() {
    if (!mounted || _activeUserId == null) return;
    context.read<NotificationProvider>().refresh(alertNew: true);
  }

  void _sync() {
    if (!mounted) return;
    final auth = _auth ?? context.read<AuthService>();
    if (!auth.isInitialized) {
      auth.initialize();
      return;
    }
    final provider = context.read<NotificationProvider>();
    if (!auth.isLoggedIn || auth.user?.token == null || auth.user!.token!.isEmpty) {
      if (_activeUserId != null) {
        _activeUserId = null;
        provider.stopMonitoring();
      }
      return;
    }

    final userId = auth.user?.id ?? '';
    if (userId.isNotEmpty) {
      if (_activeUserId != userId) {
        _activeUserId = userId;
        provider.startMonitoring(userId: userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

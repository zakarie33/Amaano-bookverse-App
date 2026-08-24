import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/utils/json_parsers.dart';

/// Polls BookVerse notifications and raises device alerts for new items.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    ApiService? api,
    PreferencesService? prefs,
  })  : _api = api ?? ApiService(),
        _prefs = prefs ?? PreferencesService();

  final ApiService _api;
  final PreferencesService _prefs;

  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _monitoring = false;
  Timer? _pollTimer;
  String? _userId;

  List<NotificationModel> get items => List.unmodifiable(_items);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get hasUnread => _unreadCount > 0;

  Future<void> startMonitoring({required String userId}) async {
    if (_monitoring && _userId == userId) {
      await refresh(alertNew: true);
      return;
    }
    stopMonitoring();
    _userId = userId;
    _monitoring = true;

    await LocalNotificationService.instance.requestPermissions();
    await refresh(alertNew: false, establishBaseline: true);
    await refresh(alertNew: true);

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      refresh(alertNew: true);
    });
  }

  void stopMonitoring() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _monitoring = false;
    _userId = null;
    _items = [];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> refresh({
    bool alertNew = false,
    bool establishBaseline = false,
  }) async {
    if (_userId == null || _userId!.isEmpty) return;
    if (!await _api.hasAuthToken()) return;

    _loading = true;
    notifyListeners();

    try {
      final data = await _api.get(ApiConstants.notifications);
      final parsed = _parseList(data);
      final unreadFromApi = _parseUnreadCount(data, parsed);

      if (establishBaseline) {
        final baselineReady = await _prefs.isNotificationBaselineReady(_userId!);
        if (!baselineReady) {
          await _prefs.markNotificationsBaseline(
            _userId!,
            parsed.map((n) => n.id).toList(),
          );
        }
      }

      if (alertNew) {
        await _alertNewItems(parsed);
      }

      _items = parsed;
      _unreadCount = unreadFromApi;
    } catch (_) {
      // Keep last known state on network errors.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      await _api.post(ApiConstants.notificationsMarkRead, body: {
        'notification_id': notification.id,
      });
      await refresh(alertNew: false);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.post(ApiConstants.notificationsMarkRead, body: {'all': true});
      await refresh(alertNew: false);
    } catch (_) {}
  }

  List<NotificationModel> _parseList(dynamic data) {
    if (data is! Map) return [];
    final list = data['notifications'] ?? data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  int _parseUnreadCount(dynamic data, List<NotificationModel> items) {
    if (data is Map && data['unread_count'] != null) {
      return parseIntSafe(data['unread_count']);
    }
    return items.where((n) => !n.isRead).length;
  }

  Future<void> _alertNewItems(List<NotificationModel> incoming) async {
    if (_userId == null) return;
    final known = await _prefs.getKnownNotificationIds(_userId!);
    final baselineReady = await _prefs.isNotificationBaselineReady(_userId!);
    if (!baselineReady) return;

    final fresh = incoming.where((n) => !known.contains(n.id)).toList();
    if (fresh.isEmpty) return;

    for (final n in fresh) {
      await LocalNotificationService.instance.showAlert(
        id: n.id,
        title: n.title,
        body: n.message,
        type: n.type,
      );
    }

    await _prefs.addKnownNotificationIds(
      _userId!,
      fresh.map((n) => n.id).toList(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

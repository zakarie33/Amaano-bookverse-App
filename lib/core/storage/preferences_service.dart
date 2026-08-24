import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';
  static const String _legacyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyInterestOnboardingComplete = 'onboarding_complete';
  static const String _keyVerified = 'email_verified';
  static const String _keyDisplayName = 'display_name';
  static const String _keyEmail = 'email';
  static const String _keyPhone = 'phone';
  static const String _keyPendingUserId = 'pending_user_id';
  static const String _keyPendingBookInterests = 'pending_book_interests';
  static const String _keyPendingUsagePreferences = 'pending_usage_preferences';
  static const String _keyNotifBaselinePrefix = 'notif_baseline_';
  static const String _keyNotifKnownPrefix = 'notif_known_';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<bool> hasSeenOnboarding() async {
    final p = await _prefs;
    if (p.containsKey(_keyHasSeenOnboarding)) {
      return p.getBool(_keyHasSeenOnboarding) ?? false;
    }
    return p.getBool(_legacyHasSeenOnboarding) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyHasSeenOnboarding, value);
    await p.remove(_legacyHasSeenOnboarding);
  }

  Future<bool> isInterestOnboardingComplete() async =>
      (await _prefs).getBool(_keyInterestOnboardingComplete) ?? false;

  Future<void> setInterestOnboardingComplete(bool value) async {
    await (await _prefs).setBool(_keyInterestOnboardingComplete, value);
  }

  /// Backwards-compatible alias used by interest-token onboarding screen.
  Future<bool> isOnboardingComplete() => isInterestOnboardingComplete();

  Future<void> setOnboardingComplete(bool value) =>
      setInterestOnboardingComplete(value);

  Future<bool> isEmailVerified() async =>
      (await _prefs).getBool(_keyVerified) ?? false;

  Future<void> setEmailVerified(bool value) async {
    await (await _prefs).setBool(_keyVerified, value);
  }

  Future<void> saveUserProfile({
    required String displayName,
    required String email,
    String? phone,
  }) async {
    final p = await _prefs;
    await p.setString(_keyDisplayName, displayName);
    await p.setString(_keyEmail, email);
    if (phone != null) await p.setString(_keyPhone, phone);
  }

  Future<String?> getDisplayName() async =>
      (await _prefs).getString(_keyDisplayName);

  Future<String?> getEmail() async => (await _prefs).getString(_keyEmail);

  Future<String?> getPhone() async => (await _prefs).getString(_keyPhone);

  Future<void> savePendingUserId(String userId) async {
    await (await _prefs).setString(_keyPendingUserId, userId);
  }

  Future<String?> getPendingUserId() async =>
      (await _prefs).getString(_keyPendingUserId);

  Future<void> clearPendingRegistration() async {
    final p = await _prefs;
    await p.remove(_keyPendingUserId);
    await p.remove(_keyVerified);
    await p.remove(_keyPendingBookInterests);
    await p.remove(_keyPendingUsagePreferences);
  }

  Future<void> savePendingProfileInterests({
    required List<String> bookInterests,
    required List<String> usagePreferences,
  }) async {
    final p = await _prefs;
    await p.setStringList(_keyPendingBookInterests, bookInterests);
    await p.setStringList(_keyPendingUsagePreferences, usagePreferences);
  }

  Future<List<String>> getPendingBookInterests() async =>
      (await _prefs).getStringList(_keyPendingBookInterests) ?? [];

  Future<List<String>> getPendingUsagePreferences() async =>
      (await _prefs).getStringList(_keyPendingUsagePreferences) ?? [];

  /// Clears auth-related prefs but keeps intro onboarding flag.
  Future<void> clearAuthPrefs() async {
    final p = await _prefs;
    await p.remove(_keyInterestOnboardingComplete);
    await p.remove(_keyVerified);
    await p.remove(_keyDisplayName);
    await p.remove(_keyEmail);
    await p.remove(_keyPhone);
    await p.remove(_keyPendingUserId);
  }

  Future<void> clearAll() async {
    final p = await _prefs;
    await p.remove(_keyHasSeenOnboarding);
    await p.remove(_legacyHasSeenOnboarding);
    await clearAuthPrefs();
  }

  String _baselineKey(String userId) => '$_keyNotifBaselinePrefix$userId';
  String _knownKey(String userId) => '$_keyNotifKnownPrefix$userId';

  Future<bool> isNotificationBaselineReady(String userId) async {
    return (await _prefs).getBool(_baselineKey(userId)) ?? false;
  }

  Future<void> markNotificationsBaseline(String userId, List<int> ids) async {
    final p = await _prefs;
    await p.setBool(_baselineKey(userId), true);
    await p.setStringList(
      _knownKey(userId),
      ids.map((id) => id.toString()).toList(),
    );
  }

  Future<Set<int>> getKnownNotificationIds(String userId) async {
    final raw = (await _prefs).getStringList(_knownKey(userId)) ?? [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> addKnownNotificationIds(String userId, List<int> ids) async {
    if (ids.isEmpty) return;
    final known = await getKnownNotificationIds(userId);
    known.addAll(ids);
    final trimmed = known.toList()..sort();
    final keep = trimmed.length > 300 ? trimmed.sublist(trimmed.length - 300) : trimmed;
    await (await _prefs).setStringList(
      _knownKey(userId),
      keep.map((id) => id.toString()).toList(),
    );
  }
}

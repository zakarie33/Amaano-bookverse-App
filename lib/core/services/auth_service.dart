import 'package:flutter/foundation.dart';

import '../constants/auth_flow_config.dart';
import '../models/api_result.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/models/user_model.dart';
import 'api_service.dart';

enum LoginFailure { none, emailNotVerified, onboardingRequired, generic }

class AuthService extends ChangeNotifier {
  AuthService({
    ApiService? apiService,
    SecureStorage? secureStorage,
    PreferencesService? preferencesService,
  })  : _api = apiService ?? ApiService(),
        _secureStorage = secureStorage ?? SecureStorage(),
        _prefs = preferencesService ?? PreferencesService();

  final ApiService _api;
  final SecureStorage _secureStorage;
  final PreferencesService _prefs;

  UserModel? _user;
  bool _initialized = false;
  bool _loading = false;
  String? _lastError;
  LoginFailure _loginFailure = LoginFailure.none;

  UserModel? get user => _user;
  bool get isInitialized => _initialized;
  bool get isLoading => _loading;
  String? get lastError => _lastError;
  LoginFailure get loginFailure => _loginFailure;

  bool get isLoggedIn {
    final token = _user?.token;
    return token != null && token.isNotEmpty;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    final token = await _secureStorage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      await _api.setAuthToken(token);
    }
    if (token == null || token.isEmpty) {
      _user = null;
      _initialized = true;
      notifyListeners();
      return;
    }
    final name = await _secureStorage.getUserName() ??
        await _prefs.getDisplayName();
    final email =
        await _secureStorage.getUserEmail() ?? await _prefs.getEmail();
    final userId = await _secureStorage.getUserId();
    _user = UserModel(
      id: userId ?? '',
      name: name ?? 'Reader',
      email: email ?? '',
      token: token,
    );
    _initialized = true;
    notifyListeners();
  }

  Future<ApiResult?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required bool privacyAgreed,
    required bool termsAgreed,
  }) async {
    _setLoading(true);
    _lastError = null;
    try {
      _user = null;
      await _api.clearAuthToken();
      await _prefs.setEmailVerified(false);
      await _prefs.setInterestOnboardingComplete(false);

      final result = await _api.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        privacyAgreed: privacyAgreed,
        termsAgreed: termsAgreed,
      );

      if (!result.success) {
        _lastError = result.message ?? 'Registration failed';
        return result;
      }

      await _prefs.saveUserProfile(
        displayName: name,
        email: email,
        phone: phone,
      );
      if (result.userId != null) {
        await _prefs.savePendingUserId(result.userId!);
      }
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _lastError = e.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _loginFailure = LoginFailure.none;
    _lastError = null;
    try {
      final result = await _api.login(email: email, password: password);

      if (!result.success) {
        final code = result.errorCode?.toLowerCase() ?? '';
        final message = result.message ?? 'Login failed';
        // TODO: Verification temporarily disabled until SMS/API verification is added.
        if (AuthFlowConfig.verificationRequired &&
            (code.contains('email_not_verified') ||
                code.contains('not_verified'))) {
          _loginFailure = LoginFailure.emailNotVerified;
          _lastError = 'Please verify your email first.';
        } else if (AuthFlowConfig.verificationRequired &&
            code.contains('onboarding')) {
          _loginFailure = LoginFailure.onboardingRequired;
          _lastError = message;
        } else if (!AuthFlowConfig.verificationRequired &&
            (code.contains('email_not_verified') ||
                code.contains('onboarding'))) {
          _loginFailure = LoginFailure.generic;
          _lastError =
              'Login is temporarily blocked by the server. Upload the latest api/login.php and api/config.php, then try again.';
        } else {
          _loginFailure = LoginFailure.generic;
          _lastError = message;
        }
        return false;
      }

      await _applyAuthResult(result, fallbackEmail: email);
      await _prefs.setEmailVerified(true);
      await _api.refreshAuthenticatedData();
      return true;
    } on ApiException catch (e) {
      final code = e.errorCode?.toLowerCase() ?? '';
      // TODO: Verification temporarily disabled until SMS/API verification is added.
      if (AuthFlowConfig.verificationRequired &&
          code.contains('email_not_verified')) {
        _loginFailure = LoginFailure.emailNotVerified;
        _lastError = 'Please verify your email first.';
      } else if (AuthFlowConfig.verificationRequired &&
          code.contains('onboarding')) {
        _loginFailure = LoginFailure.onboardingRequired;
        _lastError = e.message;
      } else if (!AuthFlowConfig.verificationRequired &&
          (code.contains('email_not_verified') ||
              code.contains('onboarding'))) {
        _loginFailure = LoginFailure.generic;
        _lastError =
            'Login is temporarily blocked by the server. Upload the latest api/login.php and api/config.php, then try again.';
      } else {
        _loginFailure = LoginFailure.generic;
        _lastError = e.message;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _lastError = null;
    try {
      final result = await _api.verifyEmailCode(email: email, code: code);
      if (!result.success) {
        _lastError = result.message ?? 'Verification failed';
        return false;
      }
      await _prefs.setEmailVerified(true);
      await _prefs.clearPendingRegistration();
      await _applyAuthResult(result, fallbackEmail: email);
      await _api.refreshAuthenticatedData();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendEmailCode(String email) async {
    _setLoading(true);
    _lastError = null;
    try {
      final result = await _api.resendEmailCode(email: email);
      if (!result.success) {
        _lastError = result.message ?? 'Could not resend code';
        return false;
      }
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResult> requestWhatsAppCode(String phone) async {
    _setLoading(true);
    try {
      return await _api.requestWhatsAppCode(phone: phone);
    } on ApiException catch (e) {
      return ApiResult(
        success: false,
        message: e.message,
        errorCode: e.errorCode,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitOnboarding({
    required List<String> bookInterests,
    required List<String> readingPreferences,
    required String academicLevel,
    required List<String> researchInterests,
  }) async {
    _setLoading(true);
    _lastError = null;
    try {
      final result = await _api.submitOnboardingProfile(
        bookInterests: bookInterests,
        readingPreferences: readingPreferences,
        academicLevel: academicLevel,
        researchInterests: researchInterests,
      );
      if (!result.success) {
        _lastError = result.message ?? 'Could not save preferences';
        return false;
      }
      await _prefs.setInterestOnboardingComplete(true);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.validationErrors?.values.join('\n') ?? e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    await _api.clearAuthToken();
    await _prefs.clearAuthPrefs();
    notifyListeners();
  }

  Future<void> _applyAuthResult(
    ApiResult result, {
    required String fallbackEmail,
  }) async {
    final token = result.token ?? result.raw?['token']?.toString();
    final userMap = result.user;
    String name = fallbackEmail;
    String id = result.userId ?? '';
    String email = result.email ?? fallbackEmail;

    if (userMap != null) {
      name = userMap['name']?.toString() ?? name;
      email = userMap['email']?.toString() ?? email;
      id = userMap['id']?.toString() ?? id;
    }

    if (token != null && token.isNotEmpty) {
      await _api.setAuthToken(token);
    } else {
      debugPrint('TOKEN SAVED: no');
    }
    if (id.isNotEmpty) await _secureStorage.saveUserId(id);
    await _secureStorage.saveUserName(name);
    await _secureStorage.saveUserEmail(email);
    await _prefs.saveUserProfile(displayName: name, email: email);
    _user = UserModel(id: id, name: name, email: email, token: token);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

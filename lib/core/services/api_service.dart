import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, HandshakeException, Platform, SocketException, TlsException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../constants/api_constants.dart';
import '../models/api_result.dart';
import '../storage/secure_storage.dart';

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.body,
    this.errorCode,
    this.validationErrors,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? body;
  final String? errorCode;
  final Map<String, String>? validationErrors;
  final Object? cause;

  bool get isNetworkFailure =>
      cause is SocketException ||
      cause is HandshakeException ||
      cause is TlsException ||
      cause is TimeoutException ||
      cause is http.ClientException;

  factory ApiException.fromResult(ApiResult result, {int? statusCode, String? body}) {
    return ApiException(
      result.message ?? 'Request failed',
      statusCode: statusCode,
      body: body,
      errorCode: result.errorCode,
      validationErrors: result.validationErrors,
    );
  }

  @override
  String toString() => message;
}

class ApiService {
  factory ApiService({
    SecureStorage? secureStorage,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
  }) {
    _shared ??= ApiService._(
      secureStorage: secureStorage ?? SecureStorage(),
      client: client,
      timeout: timeout,
    );
    return _shared!;
  }

  ApiService._({
    required SecureStorage secureStorage,
    required http.Client? client,
    required this.timeout,
  })  : _secureStorage = secureStorage,
        _client = client ?? _createDefaultClient();

  static ApiService? _shared;

  final SecureStorage _secureStorage;
  final http.Client _client;
  final Duration timeout;

  static const _userAgent = 'Mozilla/5.0 AmaanobookverseApp';

  String? _cachedToken;

  static http.Client _createDefaultClient() {
    if (kIsWeb) return http.Client();
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30);
    return IOClient(httpClient);
  }

  Duration get _requestTimeout {
    if (kIsWeb) return timeout;
    try {
      if (Platform.environment['FLUTTER_TEST'] == 'true') {
        return const Duration(milliseconds: 100);
      }
    } catch (_) {}
    return timeout;
  }

  Future<void> setAuthToken(String? token) async {
    _cachedToken = (token != null && token.isNotEmpty) ? token : null;
    if (_cachedToken != null) {
      await _secureStorage.saveAuthToken(_cachedToken!);
      debugPrint('TOKEN SAVED: yes');
    } else {
      await _secureStorage.clearSession();
      debugPrint('TOKEN SAVED: no');
    }
  }

  Future<void> clearAuthToken() => setAuthToken(null);

  Future<bool> hasAuthToken() async {
    final token = await _resolveToken(includeForPublic: true);
    return token != null && token.isNotEmpty;
  }

  Future<String?> _resolveToken({required bool includeForPublic}) async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final stored = await _secureStorage.getAuthToken();
    if (stored != null && stored.isNotEmpty) {
      _cachedToken = stored;
    }
    return _cachedToken;
  }

  Future<Map<String, String>> _headers({
    bool jsonBody = true,
    required String path,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': _userAgent,
    };
    if (jsonBody) headers['Content-Type'] = 'application/json';

    final isPublic = ApiConstants.isPublicEndpoint(path);
    if (isPublic) {
      return headers;
    }

    final token = await _resolveToken(includeForPublic: false);
    final hasToken = token != null && token.isNotEmpty;
    debugPrint('AUTH TOKEN PRESENT: ${hasToken ? 'yes' : 'no'}');
    if (hasToken) {
      headers['Authorization'] = 'Bearer $token';
      headers['X-API-Token'] = token;
      debugPrint('AUTH HEADER SENT: yes');
      debugPrint('X-API-TOKEN SENT: yes');
    } else {
      debugPrint('AUTH HEADER SENT: no');
      debugPrint('X-API-TOKEN SENT: no');
    }
    return headers;
  }

  Future<ApiResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required bool privacyAgreed,
    required bool termsAgreed,
  }) =>
      _postResult(ApiConstants.register, {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'privacy_agreed': privacyAgreed,
        'terms_agreed': termsAgreed,
      });

  Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    final data = await post(ApiConstants.login, body: {
      'email': email,
      'password': password,
    });
    return ApiResult.fromJson(data);
  }

  Future<ApiResult> verifyEmailCode({
    required String email,
    required String code,
  }) =>
      _postResult(ApiConstants.verifyCode, {
        'email': email,
        'code': code,
      });

  Future<ApiResult> resendEmailCode({required String email}) =>
      _postResult(ApiConstants.resendEmailCode, {'email': email});

  Future<ApiResult> requestWhatsAppCode({required String phone}) async {
    try {
      return await _postResult(ApiConstants.sendWhatsappCode, {'phone': phone});
    } on ApiException catch (e) {
      if (e.errorCode == 'not_available' ||
          e.message.toLowerCase().contains('not enabled')) {
        return ApiResult(
          success: false,
          message:
              'WhatsApp verification is not enabled yet. Please use email verification.',
          errorCode: 'whatsapp_not_available',
        );
      }
      rethrow;
    }
  }

  Future<ApiResult> verifyWhatsAppCode({
    required String phone,
    required String code,
  }) async {
    try {
      return await _postResult(ApiConstants.verifyWhatsappCode, {
        'phone': phone,
        'code': code,
      });
    } on ApiException catch (e) {
      if (e.errorCode == 'not_available' ||
          e.message.toLowerCase().contains('not enabled')) {
        return ApiResult(
          success: false,
          message:
              'WhatsApp verification is not enabled yet. Please use email verification.',
          errorCode: 'whatsapp_not_available',
        );
      }
      rethrow;
    }
  }

  Future<ApiResult> getHomeContent() => _getResult(ApiConstants.home);

  /// Loads books from [books.php], falling back to [home.php] when missing on host.
  Future<ApiResult> getBooks({Map<String, String>? query}) async {
    try {
      return await _getResult(ApiConstants.books, query: query);
    } on ApiException catch (e) {
      final hasFilters = query != null && query.isNotEmpty;
      if (hasFilters || !_isMissingEndpointResponse(e)) {
        rethrow;
      }
      debugPrint('books.php unavailable; using home.php book list fallback');
      return _booksFromHomeFallback();
    }
  }

  Future<ApiResult> _booksFromHomeFallback() async {
    final home = await getHomeContent();
    final raw = home.raw ?? {};
    final books = raw['books'] ?? raw['sections']?['books'] ?? [];
    return ApiResult(
      success: true,
      raw: {
        'success': true,
        'books': books is List ? books : [],
      },
    );
  }

  bool _isMissingEndpointResponse(ApiException e) {
    if (e.statusCode == 404 || e.statusCode == 403) return true;
    final message = e.message.toLowerCase();
    if (message.contains('html instead of json')) return true;
    final body = e.body?.toLowerCase() ?? '';
    return body.contains('error 404') ||
        body.contains('<!doctype html') ||
        body.contains('<html');
  }

  Future<ApiResult> getArticles({Map<String, String>? query}) =>
      _getResult(ApiConstants.articles, query: query);

  Future<ApiResult> getResearch({Map<String, String>? query}) =>
      _getResult(ApiConstants.research, query: query);

  Future<ApiResult> getAudiobooks({Map<String, String>? query}) =>
      _getResult(ApiConstants.audiobooks, query: query);

  Future<ApiResult> getAnnouncements() => _getResult(ApiConstants.announcements);

  Future<ApiResult> getContentDetails(int id) =>
      _getResult(ApiConstants.contentDetails, query: {'id': '$id'});

  Future<ApiResult> submitReview({
    required int contentId,
    required int rating,
    required String reviewText,
    String? reviewTitle,
  }) =>
      _postResult(ApiConstants.contentReview, {
        'content_id': contentId,
        'rating': rating,
        'review_text': reviewText,
        if (reviewTitle != null && reviewTitle.isNotEmpty)
          'review_title': reviewTitle,
      });

  Future<ApiResult> submitComment({
    required int contentId,
    required String commentText,
  }) =>
      _postResult(ApiConstants.contentComment, {
        'content_id': contentId,
        'comment_text': commentText,
      });

  Future<ApiResult> toggleFavorite(int contentId) =>
      _postResult(ApiConstants.favoriteToggle, {'content_id': contentId});

  Future<ApiResult> getUserActivities() =>
      _getResult(ApiConstants.userActivities);

  /// Optional connectivity probe — not used to block UI.
  Future<bool> pingServer() async {
    try {
      await get(ApiConstants.ping);
      return true;
    } catch (e) {
      debugPrint('API PING FAILED: $e');
      return false;
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    return _request(
      () async {
        var uri = Uri.parse(ApiConstants.endpoint(path));
        if (query != null && query.isNotEmpty) {
          uri = uri.replace(queryParameters: query);
        }
        _logRequest('GET', uri, path: path);
        final headers = await _headers(path: path);
        final response = await _client.get(uri, headers: headers);
        _logResponse(response, path: path);
        return response;
      },
      debugContext: path,
    );
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _request(
      () async {
        final uri = Uri.parse(ApiConstants.endpoint(path));
        _logRequest('POST', uri, body: body, path: path);
        final headers = await _headers(path: path);
        final response = await _client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        _logResponse(response, path: path);
        return response;
      },
      debugContext: path,
    );
  }

  Future<ApiResult> submitOnboardingProfile({
    required List<String> bookInterests,
    required List<String> readingPreferences,
    required String academicLevel,
    required List<String> researchInterests,
  }) =>
      _postResult(ApiConstants.onboarding, {
        'book_interests': bookInterests,
        'reading_preferences': readingPreferences,
        'academic_level': academicLevel,
        'research_interests': researchInterests,
      });

  Future<ApiResult> refreshAuthenticatedData() async {
    final results = <String, dynamic>{};
    for (final path in [
      ApiConstants.notifications,
      ApiConstants.profile,
      ApiConstants.userLibrary,
      ApiConstants.orders,
    ]) {
      try {
        results[path] = await get(path);
      } catch (e) {
        debugPrint('AUTH REFRESH FAILED [$path]: $e');
      }
    }
    return ApiResult(success: true, raw: results);
  }

  Future<ApiResult> _getResult(String path, {Map<String, String>? query}) async {
    final data = await get(path, query: query);
    return ApiResult.fromJson(data);
  }

  Future<ApiResult> _postResult(
    String path,
    Map<String, dynamic> body,
  ) async {
    final data = await post(path, body: body);
    return ApiResult.fromJson(data);
  }

  Future<dynamic> _request(
    Future<http.Response> Function() call, {
    String? debugContext,
  }) async {
    final response = await _send(call, debugContext: debugContext);
    return _decodeResponse(response, debugContext: debugContext);
  }

  void _logRequest(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    String? path,
  }) {
    debugPrint('API BASE: ${ApiConstants.baseUrl}');
    debugPrint('API REQUEST: $method $uri');
    if (body != null) {
      debugPrint('API BODY: ${jsonEncode(body)}');
    }
    if (path != null && path == ApiConstants.login) {
      debugPrint('LOGIN STATUS: pending');
    }
  }

  void _logResponse(http.Response response, {String? path}) {
    if (path == ApiConstants.login) {
      debugPrint('LOGIN STATUS: ${response.statusCode}');
    }
    debugPrint('API STATUS: ${response.statusCode}');
    final preview = response.body.length > 500
        ? '${response.body.substring(0, 500)}…'
        : response.body;
    debugPrint('API RESPONSE: $preview');
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    String? debugContext,
  }) async {
    try {
      return await request().timeout(_requestTimeout);
    } on TimeoutException catch (e, st) {
      debugPrint('API TIMEOUT [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        'Request timed out after ${_requestTimeout.inSeconds}s.',
        cause: e,
      );
    } on SocketException catch (e, st) {
      debugPrint('API SOCKET ERROR [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        'Network error: ${e.message}',
        cause: e,
      );
    } on HandshakeException catch (e, st) {
      debugPrint('API TLS HANDSHAKE [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        'TLS handshake failed: ${e.message}',
        cause: e,
      );
    } on TlsException catch (e, st) {
      debugPrint('API TLS ERROR [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        'TLS error: ${e.message}',
        cause: e,
      );
    } on http.ClientException catch (e, st) {
      debugPrint('API CLIENT ERROR [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        'HTTP client error: ${e.message}',
        cause: e,
      );
    } catch (e, st) {
      debugPrint('API UNEXPECTED [$debugContext]: $e');
      debugPrint('$st');
      throw ApiException(
        e.toString(),
        cause: e,
      );
    }
  }

  dynamic _decodeResponse(http.Response response, {String? debugContext}) {
    final body = response.body;
    if (body.isNotEmpty && _looksLikeHtml(body)) {
      debugPrint('API HTML RESPONSE [$debugContext]: ${body.length > 500 ? '${body.substring(0, 500)}…' : body}');
      throw ApiException(
        'Server returned HTML instead of JSON. Check hosting URL or API path.',
        statusCode: response.statusCode,
        body: body,
      );
    }

    dynamic data;
    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body);
      } catch (e, st) {
        debugPrint('API JSON PARSE ERROR [$debugContext]: $e');
        debugPrint('API RAW BODY: $body');
        debugPrint('$st');
        throw ApiException(
          'Invalid JSON response (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
          body: body,
          cause: e,
        );
      }
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      final result = ApiResult.fromJson(
        data is Map<String, dynamic> ? data : {'message': data?.toString()},
      );
      debugPrint(
        'API HTTP ERROR [$debugContext]: ${response.statusCode} ${result.message}',
      );
      throw ApiException.fromResult(
        result,
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    if (data is Map<String, dynamic> &&
        (data['success'] == false || data['status'] == 'error')) {
      final result = ApiResult.fromJson(data);
      debugPrint('API BUSINESS ERROR [$debugContext]: ${result.message}');
      throw ApiException.fromResult(
        result,
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    return data;
  }

  bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<html') ||
        trimmed.contains('<!doctype html') ||
        trimmed.startsWith('<section') ||
        trimmed.contains('<head>') ||
        trimmed.contains('error 404');
  }

  void dispose() => _client.close();
}

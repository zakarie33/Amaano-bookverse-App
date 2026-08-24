class ApiResult {
  const ApiResult({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.errorCode,
    this.validationErrors,
    this.raw,
  });

  final bool success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? user;
  final String? errorCode;
  final Map<String, String>? validationErrors;
  final Map<String, dynamic>? raw;

  factory ApiResult.fromJson(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const ApiResult(success: true);
    }

    final success =
        data['success'] != false && data['status']?.toString() != 'error';
    final errors = data['errors'] ?? data['validation_errors'];
    Map<String, String>? validationErrors;
    if (errors is Map) {
      validationErrors = errors.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }

    final user = data['user'];
    return ApiResult(
      success: success,
      message: data['message']?.toString(),
      token: (data['token'] ?? data['access_token'])?.toString(),
      user: user is Map<String, dynamic>
          ? user
          : (user is Map ? Map<String, dynamic>.from(user) : null),
      errorCode: (data['error_code'] ?? data['code'])?.toString(),
      validationErrors: validationErrors,
      raw: data,
    );
  }

  String? get userId =>
      user?['id']?.toString() ?? raw?['user_id']?.toString();

  String? get email =>
      user?['email']?.toString() ?? raw?['email']?.toString();
}

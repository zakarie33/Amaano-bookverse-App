import 'package:flutter/foundation.dart';



import '../constants/api_constants.dart';



/// Resolves relative media paths to full hosted URLs for covers/posters.

class MediaUrl {

  MediaUrl._();



  static final _legacyHosts = RegExp(
    r'^https?://(localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.\d+\.\d+|amaanobookverse\.great-site\.net)(:\d+)?(/bookverse)?',
    caseSensitive: false,
  );

  static final _httpsAtwebpages = RegExp(
    r'^https://amaanobookverse\.atwebpages\.com',
    caseSensitive: false,
  );



  /// Rewrites stale local/LAN asset hosts to the current hosted base URL.

  static String normalizeLegacyHost(String url) {
    if (_legacyHosts.hasMatch(url)) {
      final uri = Uri.tryParse(url);
      if (uri == null) return url;
      final path = uri.path;
      if (path.contains('/api/')) {
        final apiPath = path.substring(path.indexOf('/api/'));
        return '${ApiConstants.baseUrl}${apiPath.replaceFirst('/api/', '')}';
      }
      return '${ApiConstants.serverPublicBase}$path';
    }
    if (_httpsAtwebpages.hasMatch(url)) {
      return url.replaceFirst(
        RegExp(r'^https://amaanobookverse\.atwebpages\.com', caseSensitive: false),
        ApiConstants.serverPublicBase,
      );
    }
    return url;
  }



  static String? resolve(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();
    String url;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      url = normalizeLegacyHost(value);
    } else {
      final path = value.startsWith('/') ? value : '/$value';
      url = '${ApiConstants.serverPublicBase}$path';
    }

    url = _coverProxyIfNeeded(url);

    if (kDebugMode) debugPrint('IMAGE URL: $url');
    return url;
  }

  /// AwardSpace may block direct /uploads/covers/ — route through cover.php.
  static String _coverProxyIfNeeded(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    var path = uri.path;
    if (path.startsWith('/')) path = path.substring(1);
    const proxiedPrefixes = [
      'uploads/covers/',
      'uploads/hero_spotlight/',
      'uploads/announcements/',
    ];
    for (final prefix in proxiedPrefixes) {
      if (path.startsWith(prefix)) {
        return '${ApiConstants.baseUrl}cover.php?path=${Uri.encodeComponent(path)}';
      }
    }
    return url;
  }



  static String? firstNonEmpty(Iterable<String?> values) {

    for (final value in values) {

      final resolved = resolve(value);

      if (resolved != null && resolved.isNotEmpty) return resolved;

    }

    return null;

  }

}



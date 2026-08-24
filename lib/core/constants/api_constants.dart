/// Central API configuration — all screens must use [baseUrl] via [endpoint].
class ApiConstants {
  ApiConstants._();

  /// Hosted BookVerse PHP API (AwardSpace).
  static const String baseUrl =
      'http://amaanobookverse.atwebpages.com/api/';

  /// Optional health check (no DB). Not required for app startup.
  static const String ping = 'ping.php';

  /// Public site root for cover/poster assets (without `/api`).
  static String get serverPublicBase {
    if (baseUrl.endsWith('/api/')) {
      return baseUrl.substring(0, baseUrl.length - 5);
    }
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl.replaceAll(RegExp(r'/api/?$'), '');
  }

  static String endpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl$cleanPath';
  }

  static String readBookUrl(int contentId) =>
      endpoint('read_book.php?id=$contentId');

  static const String login = 'login.php';
  static const String register = 'register.php';
  static const String verifyCode = 'verify_code.php';
  static const String resendEmailCode = 'resend_email_code.php';
  static const String sendWhatsappCode = 'send_whatsapp_code.php';
  static const String verifyWhatsappCode = 'verify_whatsapp_code.php';
  static const String onboarding = 'onboarding.php';
  static const String home = 'home.php';
  static const String books = 'books.php';
  static const String articles = 'articles.php';
  static const String research = 'research.php';
  static const String audiobooks = 'audiobooks.php';
  static const String categories = 'categories.php';
  static const String contentDetails = 'content_details.php';
  static const String bookDetails = 'book_details.php';
  static const String readBook = 'read_book.php';
  static const String paymentMethods = 'payment_methods.php';
  static const String cartCheckout = 'cart_checkout.php';
  static const String orders = 'orders.php';
  static const String myPurchases = 'my_purchases.php';
  static const String userLibrary = 'user_library.php';
  static const String profile = 'profile.php';
  static const String profileUpdate = 'profile_update.php';
  static const String notifications = 'notifications.php';
  static const String notificationsMarkRead = 'notifications_mark_read.php';
  static const String announcements = 'announcements.php';
  static const String contentReview = 'content_review.php';
  static const String contentComment = 'content_comment.php';
  static const String favoriteToggle = 'favorite_toggle.php';
  static const String favorites = 'favorites.php';
  static const String submitArticle = 'submit_article.php';
  static const String submitResearch = 'submit_research.php';
  static const String userActivities = 'user_activities.php';

  /// Endpoints that must not send Authorization (public / pre-auth).
  static const Set<String> publicEndpoints = {
    ping,
    books,
    home,
    categories,
    bookDetails,
    contentDetails,
    announcements,
    articles,
    research,
    audiobooks,
    login,
    register,
    verifyCode,
    resendEmailCode,
    'resend_code.php',
    'debug.php',
  };

  static bool isPublicEndpoint(String path) {
    final normalized = path.split('?').first.replaceAll('\\', '/');
    final name = normalized.contains('/')
        ? normalized.substring(normalized.lastIndexOf('/') + 1)
        : normalized;
    return publicEndpoints.contains(name);
  }
}

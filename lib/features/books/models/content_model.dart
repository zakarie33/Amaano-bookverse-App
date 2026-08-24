import '../../../core/constants/api_constants.dart';
import '../../../core/utils/json_parsers.dart';
import '../../../core/utils/media_url.dart';

class ContentModel {
  const ContentModel({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    this.type,
    this.price,
    this.duration,
    this.rating,
    this.reviewCount,
    this.isPaid,
    this.featured,
    this.category,
    this.publicationYear,
    this.readingTime,
    this.fileUrl,
    this.audioUrl,
    this.readUrl,
    this.listenUrl,
    this.hasAccess,
    this.hasPdf,
    this.paymentStatus,
  });

  final int id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String? type;
  final double? price;
  final String? duration;
  final double? rating;
  final int? reviewCount;
  final bool? isPaid;
  final bool? featured;
  final String? category;
  final int? publicationYear;
  final String? readingTime;
  final String? fileUrl;
  final String? audioUrl;
  final String? readUrl;
  final String? listenUrl;
  final bool? hasAccess;
  final bool? hasPdf;
  final String? paymentStatus;

  bool get isFreeContent {
    if (isPaid == true) return false;
    if (isPaid == false) return true;
    final p = price ?? 0;
    return p <= 0;
  }

  bool get hasAudio =>
      (audioUrl != null && audioUrl!.isNotEmpty) ||
      (type?.toLowerCase() == 'audiobook');

  bool get canRead =>
      (readUrl != null && readUrl!.isNotEmpty) ||
      (hasPdf == true && userCanAccessContent);

  bool get canListen => hasAudio;

  bool get userCanAccessContent =>
      isFreeContent || (hasAccess == true);

  bool get isPendingPayment =>
      paymentStatus?.toLowerCase() == 'pending';

  bool get isPaymentLocked =>
      !isFreeContent && !userCanAccessContent && !isPendingPayment;

  String? get typeLabel {
    if (type == null) return null;
    switch (type!.toLowerCase()) {
      case 'audiobook':
      case 'audio':
        return 'Audiobook';
      case 'ebook':
      case 'book':
        return 'Book';
      default:
        return type;
    }
  }

  String get secureReadUrl => ApiConstants.readBookUrl(id);

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    final year = parseIntSafe(json['publication_year']);
    final id = parseIntSafe(json['id']);
    final hasAccess = json.containsKey('has_access')
        ? parseBoolSafe(json['has_access'])
        : null;
    final readFromApi = json['read_url']?.toString();
    final readUrl = readFromApi != null && readFromApi.isNotEmpty
        ? MediaUrl.resolve(readFromApi) ?? ApiConstants.readBookUrl(id)
        : null;

    return ContentModel(
      id: id,
      title: json['title']?.toString() ?? 'Untitled',
      author: json['author']?.toString(),
      description:
          json['description']?.toString() ?? json['summary']?.toString(),
      coverUrl: MediaUrl.firstNonEmpty([
        json['cover_url']?.toString(),
        json['cover']?.toString(),
        json['poster_url']?.toString(),
        json['image_url']?.toString(),
        json['thumbnail']?.toString(),
      ]),
      type: json['type']?.toString() ?? json['content_type']?.toString(),
      price: parseDoubleNullable(json['price']),
      duration: json['duration']?.toString(),
      rating: parseDoubleNullable(json['rating']),
      reviewCount: json.containsKey('review_count')
          ? parseIntSafe(json['review_count'])
          : null,
      isPaid: json.containsKey('is_paid') ? parseBoolSafe(json['is_paid']) : null,
      featured:
          json.containsKey('featured') ? parseBoolSafe(json['featured']) : null,
      category:
          json['category']?.toString() ?? json['category_name']?.toString(),
      publicationYear: year > 0 ? year : null,
      readingTime:
          json['reading_time']?.toString() ?? json['duration']?.toString(),
      fileUrl: null,
      audioUrl: MediaUrl.resolve(
        json['audio_url']?.toString() ?? json['listen_url']?.toString(),
      ),
      readUrl: readUrl,
      listenUrl: MediaUrl.resolve(
        json['listen_url']?.toString() ?? json['audio_url']?.toString(),
      ),
      hasAccess: hasAccess,
      hasPdf: json.containsKey('has_pdf')
          ? parseBoolSafe(json['has_pdf'])
          : null,
      paymentStatus: json['payment_status']?.toString(),
    );
  }
}

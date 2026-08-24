import '../../../core/utils/json_parsers.dart';
import '../../../core/utils/media_url.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    this.teaser,
    this.posterUrl,
    this.linkUrl,
  });

  final int id;
  final String title;
  final String? teaser;
  final String? posterUrl;
  final String? linkUrl;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: parseIntSafe(json['id']),
      title: json['title']?.toString() ?? 'Announcement',
      teaser: json['teaser']?.toString(),
      posterUrl: MediaUrl.firstNonEmpty([
        json['poster_url']?.toString(),
        json['image_url']?.toString(),
        json['cover_url']?.toString(),
        json['cover']?.toString(),
      ]),
      linkUrl: json['link_href']?.toString() ?? json['link_url']?.toString(),
    );
  }
}

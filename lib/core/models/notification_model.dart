import '../utils/json_parsers.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.link,
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String? type;
  final String? link;
  final bool isRead;
  final String? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: parseIntSafe(json['id']),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: json['type']?.toString(),
      link: json['link']?.toString(),
      isRead: parseBoolSafe(json['is_read']),
      createdAt: json['created_at']?.toString(),
    );
  }
}

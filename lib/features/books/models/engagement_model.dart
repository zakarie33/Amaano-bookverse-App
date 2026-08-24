import '../../../core/utils/json_parsers.dart';

class ContentReviewModel {
  const ContentReviewModel({
    required this.id,
    required this.rating,
    required this.reviewText,
    this.reviewTitle,
    this.userName,
    this.createdAt,
  });

  final int id;
  final int rating;
  final String reviewText;
  final String? reviewTitle;
  final String? userName;
  final String? createdAt;

  factory ContentReviewModel.fromJson(Map<String, dynamic> json) {
    return ContentReviewModel(
      id: parseIntSafe(json['id']),
      rating: parseIntSafe(json['rating']),
      reviewText: json['review_text']?.toString() ?? '',
      reviewTitle: json['review_title']?.toString(),
      userName: json['user_name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ContentCommentModel {
  const ContentCommentModel({
    required this.id,
    required this.commentText,
    this.userName,
    this.createdAt,
  });

  final int id;
  final String commentText;
  final String? userName;
  final String? createdAt;

  factory ContentCommentModel.fromJson(Map<String, dynamic> json) {
    return ContentCommentModel(
      id: parseIntSafe(json['id']),
      commentText: json['comment_text']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class UserActivityModel {
  const UserActivityModel({
    required this.type,
    required this.contentId,
    required this.contentTitle,
    this.contentType,
    this.rating,
    this.reviewText,
    this.commentText,
    this.createdAt,
  });

  final String type;
  final int contentId;
  final String contentTitle;
  final String? contentType;
  final int? rating;
  final String? reviewText;
  final String? commentText;
  final String? createdAt;

  String get label {
    switch (type) {
      case 'review':
        return 'Reviewed';
      case 'comment':
        return 'Commented on';
      case 'favorite':
        return 'Favorited';
      default:
        return 'Activity on';
    }
  }

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      type: json['type']?.toString() ?? 'activity',
      contentId: parseIntSafe(json['content_id'] ?? json['id']),
      contentTitle: json['content_title']?.toString() ?? 'Content',
      contentType: json['content_type']?.toString(),
      rating: json.containsKey('rating') ? parseIntSafe(json['rating']) : null,
      reviewText: json['review_text']?.toString(),
      commentText: json['comment_text']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

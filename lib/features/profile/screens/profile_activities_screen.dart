import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../books/models/content_model.dart';
import '../../books/models/engagement_model.dart';
import '../../books/screens/book_details_screen.dart';

class ProfileActivitiesScreen extends StatefulWidget {
  const ProfileActivitiesScreen({super.key});

  static const String routeName = '/profile-activities';

  @override
  State<ProfileActivitiesScreen> createState() => _ProfileActivitiesScreenState();
}

class _ProfileActivitiesScreenState extends State<ProfileActivitiesScreen> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  List<UserActivityModel> _activities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.getUserActivities();
      final raw = result.raw ?? {};
      final list = raw['activities'];
      final items = <UserActivityModel>[];
      if (list is List) {
        for (final e in list) {
          if (e is Map) {
            items.add(UserActivityModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _activities = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'review':
        return Icons.rate_review_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _subtitle(UserActivityModel item) {
    if (item.type == 'review') {
      final stars = '★' * (item.rating ?? 0);
      final text = item.reviewText ?? '';
      return '$stars ${text.isNotEmpty ? text : item.contentTitle}';
    }
    if (item.type == 'comment') {
      return item.commentText ?? '';
    }
    return item.contentTitle;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.espresso,
        appBar: AppBar(
          title: const Text('Activities'),
          backgroundColor: AppColors.espresso,
          foregroundColor: AppColors.tortilla,
        ),
        body: const Center(
          child: Text(
            'Sign in to view your activities.',
            style: TextStyle(color: AppColors.mutedText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.espresso,
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.tortilla,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.caramel),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.mutedText)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _activities.isEmpty
                  ? const Center(
                      child: Text(
                        'No activities yet.\nReview, comment, or favorite titles to see them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.mutedText, height: 1.5),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.caramel,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _activities[index];
                          return Card(
                            color: AppColors.espressoSoft.withValues(alpha: 0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Icon(_iconFor(item.type),
                                  color: AppColors.caramel),
                              title: Text(
                                '${item.label} ${item.contentTitle}',
                                style: const TextStyle(
                                  color: AppColors.tortilla,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _subtitle(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  BookDetailsScreen.routeName,
                                  arguments: ContentModel(
                                    id: item.contentId,
                                    title: item.contentTitle,
                                    type: item.contentType,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

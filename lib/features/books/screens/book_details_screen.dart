import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/widgets/login_required_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../audiobooks/screens/audio_player_screen.dart';
import '../../cart/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/screens/checkout_screen.dart';
import '../models/content_model.dart';
import '../models/engagement_model.dart';
import 'book_reader_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, this.content});

  final ContentModel? content;

  static const String routeName = '/book-details';

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  ContentModel? _item;
  List<ContentReviewModel> _reviews = [];
  List<ContentCommentModel> _comments = [];
  bool _isFavorite = false;
  bool _userHasReviewed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int _resolveId() {
    if (widget.content != null) return widget.content!.id;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContentModel) return args.id;
    if (args is int) return args;
    return 0;
  }

  Future<void> _load() async {
    final id = _resolveId();
    if (id <= 0) {
      setState(() {
        _loading = false;
        _error = 'Invalid content.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getContentDetails(id);
      final raw = result.raw ?? {};
      final contentRaw = raw['content'] ?? raw['data'];
      if (contentRaw is! Map) throw Exception('Content not found.');
      final reviewsRaw = raw['reviews'];
      final commentsRaw = raw['comments'];
      if (!mounted) return;
      setState(() {
        _item = ContentModel.fromJson(Map<String, dynamic>.from(contentRaw));
        _reviews = reviewsRaw is List
            ? reviewsRaw
                .whereType<Map>()
                .map((e) =>
                    ContentReviewModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [];
        _comments = commentsRaw is List
            ? commentsRaw
                .whereType<Map>()
                .map((e) =>
                    ContentCommentModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [];
        _isFavorite = raw['is_favorite'] == true;
        _userHasReviewed = raw['user_has_reviewed'] == true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _reloadEngagement() async {
    final id = _item?.id ?? _resolveId();
    if (id <= 0 || !mounted) return;

    try {
      final result = await _api.getContentDetails(id);
      final raw = result.raw ?? {};
      final contentRaw = raw['content'] ?? raw['data'];
      final reviewsRaw = raw['reviews'];
      final commentsRaw = raw['comments'];
      if (!mounted) return;
      setState(() {
        if (contentRaw is Map) {
          _item = ContentModel.fromJson(Map<String, dynamic>.from(contentRaw));
        }
        _reviews = reviewsRaw is List
            ? reviewsRaw
                .whereType<Map>()
                .map((e) =>
                    ContentReviewModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : _reviews;
        _comments = commentsRaw is List
            ? commentsRaw
                .whereType<Map>()
                .map((e) =>
                    ContentCommentModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : _comments;
        _isFavorite = raw['is_favorite'] == true;
        _userHasReviewed = raw['user_has_reviewed'] == true;
      });
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final item = _item;
    if (item == null) return;
    if (!context.read<AuthService>().isLoggedIn) {
      showLoginRequiredDialog(context);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await _api.toggleFavorite(item.id);
      final raw = result.raw ?? {};
      if (!mounted) return;
      setState(() => _isFavorite = raw['is_favorite'] == true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showReviewDialog() async {
    final item = _item;
    if (item == null) return;
    if (_userHasReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already reviewed this title.')),
      );
      return;
    }

    final result = await showDialog<_ReviewFormData>(
      context: context,
      builder: (_) => const _ReviewDialog(),
    );
    if (result == null || !mounted) return;
    await _submitReview(result);
  }

  Future<void> _submitReview(_ReviewFormData data) async {
    final item = _item;
    if (item == null || !mounted) return;
    if (!context.read<AuthService>().isLoggedIn) {
      showLoginRequiredDialog(context);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.submitReview(
        contentId: item.id,
        rating: data.rating,
        reviewText: data.reviewText,
        reviewTitle: data.reviewTitle,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Review posted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      await _reloadEngagement();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _showCommentDialog() async {
    final item = _item;
    if (item == null) return;

    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _CommentDialog(),
    );
    if (text == null || text.isEmpty || !mounted) return;
    await _submitComment(text);
  }

  Future<void> _submitComment(String text) async {
    final item = _item;
    if (item == null || !mounted) return;
    if (!context.read<AuthService>().isLoggedIn) {
      showLoginRequiredDialog(context);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.submitComment(contentId: item.id, commentText: text);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Comment posted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      await _reloadEngagement();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tortilla,
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.tortilla,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? AppColors.caramel : AppColors.tortilla,
            onPressed: _toggleFavorite,
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.caramel),
      );
    }
    if (_error != null || _item == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Not found',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textOnCardMuted)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final item = _item!;
    final cart = context.watch<CartProvider>();
    final rating = item.rating ?? 0;
    final reviewCount = item.reviewCount ?? _reviews.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 0.72,
              child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.caramel,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, _, __) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          if (item.typeLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.caramel.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.typeLabel!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.espresso)),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textOnCard,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (item.author != null) ...[
            const SizedBox(height: 6),
            Text('by ${item.author}',
                style: const TextStyle(color: AppColors.textOnCardMuted)),
          ],
          const SizedBox(height: 10),
          RatingStars(
            rating: rating,
            reviewCount: reviewCount,
          ),
          const SizedBox(height: 16),
          Text(
            item.description ?? 'No description available.',
            style: const TextStyle(
              color: AppColors.textOnCardMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                icon: Icons.rate_review_outlined,
                label: 'Review',
                onTap: () => requireLogin(context, () => _showReviewDialog()),
              ),
              _ActionChip(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: () => requireLogin(context, () => _showCommentDialog()),
              ),
              _ActionChip(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                label: _isFavorite ? 'Favorited' : 'Favorite',
                onTap: _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (item.canRead || !item.hasAudio) ...[
            if (item.userCanAccessContent)
              AppButton(
                label: 'Read in App',
                icon: Icons.menu_book_rounded,
                onPressed: () => requireLogin(context, () {
                  Navigator.of(context).pushNamed(
                    BookReaderScreen.routeName,
                    arguments: item,
                  );
                }),
              )
            else if (item.isPendingPayment)
              AppButton(
                label: 'Waiting for Admin Approval',
                icon: Icons.hourglass_top_rounded,
                onPressed: null,
              )
            else
              AppButton(
                label: 'Buy Now',
                icon: Icons.shopping_bag_outlined,
                onPressed: () => requireLogin(context, () {
                  if (!cart.contains(item.id)) cart.addItem(item);
                  Navigator.of(context).pushNamed(CheckoutScreen.routeName);
                }),
              ),
            const SizedBox(height: 12),
          ],
          if (item.canListen || item.hasAudio) ...[
            AppButton(
              label: 'Listen',
              outlined: true,
              icon: Icons.headphones_rounded,
              onPressed: () => requireLogin(context, () {
                Navigator.of(context).pushNamed(
                  AudioPlayerScreen.routeName,
                  arguments: item,
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
          if (!item.isFreeContent) ...[
            AppButton(
              label: cart.contains(item.id) ? 'In cart' : 'Add to cart',
              icon: Icons.add_shopping_cart,
              onPressed: () => requireLogin(context, () {
                if (!cart.contains(item.id)) cart.addItem(item);
                Navigator.of(context).pushNamed(CartScreen.routeName);
              }),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Checkout',
              outlined: true,
              icon: Icons.payment_rounded,
              onPressed: () => requireLogin(
                context,
                () => Navigator.of(context).pushNamed(CheckoutScreen.routeName),
              ),
            ),
          ],
          const SizedBox(height: 28),
          _sectionTitle('Reviews (${_reviews.length})'),
          const SizedBox(height: 10),
          if (_reviews.isEmpty)
            const Text('No reviews yet. Be the first to review.',
                style: TextStyle(color: AppColors.textOnCardMuted))
          else
            ..._reviews.map(_reviewTile),
          const SizedBox(height: 24),
          _sectionTitle('Comments (${_comments.length})'),
          const SizedBox(height: 10),
          if (_comments.isEmpty)
            const Text('No comments yet.',
                style: TextStyle(color: AppColors.textOnCardMuted))
          else
            ..._comments.map(_commentTile),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textOnCard,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _reviewTile(ContentReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName ?? 'Reader',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (i) => Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.caramel,
                    )),
              ),
            ],
          ),
          if (review.reviewTitle != null && review.reviewTitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.reviewTitle!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.espresso)),
          ],
          const SizedBox(height: 4),
          Text(review.reviewText,
              style: const TextStyle(
                  color: AppColors.textOnCardMuted, height: 1.4)),
        ],
      ),
    );
  }

  Widget _commentTile(ContentCommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.userName ?? 'Reader',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 4),
          Text(comment.commentText,
              style: const TextStyle(
                  color: AppColors.textOnCardMuted, height: 1.4)),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: AppColors.tortillaAlt,
      child: const Icon(Icons.menu_book_rounded,
          size: 72, color: AppColors.espressoSoft),
    );
  }
}

class _ReviewFormData {
  const _ReviewFormData({
    required this.rating,
    required this.reviewText,
    this.reviewTitle,
  });

  final int rating;
  final String reviewText;
  final String? reviewTitle;
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 5;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _textCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _ReviewFormData(
        rating: _rating,
        reviewText: _textCtrl.text.trim(),
        reviewTitle: _titleCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cream,
      title: const Text('Write a review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 2,
              runSpacing: 4,
              children: List.generate(5, (i) {
                return InkWell(
                  onTap: () => setState(() => _rating = i + 1),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.caramel,
                      size: 28,
                    ),
                  ),
                );
              }),
            ),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your review',
                hintText: 'At least 10 characters',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Post')),
      ],
    );
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog();

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cream,
      title: const Text('Add a comment'),
      content: TextField(
        controller: _ctrl,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Share your thoughts…'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Post')),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tortillaAlt,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.espresso),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textOnCard,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

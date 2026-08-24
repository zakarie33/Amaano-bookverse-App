import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/utils/content_filters.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/home_skeleton.dart';
import '../../audiobooks/screens/audio_player_screen.dart';
import '../../books/models/content_model.dart';
import '../../books/screens/book_details_screen.dart';
import '../../cart/cart_provider.dart';

class AudiobooksScreen extends StatefulWidget {
  const AudiobooksScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  static const String routeName = '/audiobooks';

  @override
  State<AudiobooksScreen> createState() => _AudiobooksScreenState();
}

class _AudiobooksScreenState extends State<AudiobooksScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  bool _networkError = false;
  List<ContentModel> _items = [];
  String _filter = 'all';

  static const _filters = [
    ('all', 'All'),
    ('free', 'Free'),
    ('paid', 'Paid'),
    ('featured', 'Featured'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, String>? _queryForFilter() {
    final q = _searchController.text.trim();
    final map = <String, String>{};
    if (q.isNotEmpty) map['q'] = q;
    switch (_filter) {
      case 'free':
        map['access'] = 'free';
        break;
      case 'paid':
        map['access'] = 'paid';
        break;
      case 'featured':
        map['featured'] = '1';
        break;
    }
    return map.isEmpty ? null : map;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _networkError = false;
    });
    try {
      final query = _queryForFilter();
      List<ContentModel> audio = [];
      List<ContentModel> booksWithAudio = [];
      String? audioError;
      var networkFailure = false;

      try {
        final audioData = await _api.get(ApiConstants.audiobooks, query: query);
        audio = _parseList(audioData);
      } on ApiException catch (e) {
        audioError = e.message;
        networkFailure = e.isNetworkFailure;
      } catch (e) {
        audioError = e.toString();
      }

      try {
        final booksResult = await _api.getBooks(query: query);
        booksWithAudio =
            ContentFilters.audiobooksOnly(_parseList(booksResult.raw ?? {}));
      } on ApiException catch (e) {
        debugPrint('Optional books.php load for audiobooks failed: $e');
      } catch (e) {
        debugPrint('Optional books.php load for audiobooks failed: $e');
      }

      _items = ContentFilters.mergeUniqueById(audio, booksWithAudio);
      _error = _items.isEmpty ? audioError : null;
      _networkError = _items.isEmpty && networkFailure;
    } on ApiException catch (e) {
      _items = [];
      _error = e.message;
      _networkError = e.isNetworkFailure;
    } catch (e) {
      _items = [];
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ContentModel> _parseList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final list = data['audiobooks'] ??
          data['books'] ??
          data['data'] ??
          data['items'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  void _onAction(ContentModel item) {
    requireLogin(context, () {
      if (item.isFreeContent) {
        Navigator.of(context).pushNamed(
          AudioPlayerScreen.routeName,
          arguments: item,
        );
        return;
      }
      context.read<CartProvider>().addItem(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.title}" added to cart'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final embedded = widget.embeddedInShell;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.espresso, AppColors.espressoDark],
        ),
      ),
      child: embedded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildAudiobooksContent(context),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildAudiobooksContent(context, showHeader: true),
              ),
            ),
    );
  }

  List<Widget> _buildAudiobooksContent(BuildContext context, {bool showHeader = false}) {
    return [
      if (showHeader)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audiobooks',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.tortilla,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Listen on the go',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.caramel.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: AppColors.caramel,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.tortilla),
                decoration: InputDecoration(
                  hintText: 'Search audiobooks…',
                  hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.8)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.caramel),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.caramel),
                    onPressed: _load,
                  ),
                  filled: true,
                  fillColor: AppColors.espressoSoft.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = _filters[index];
                  final selected = _filter == entry.$1;
                  return FilterChip(
                    label: Text(entry.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _filter = entry.$1);
                      _load();
                    },
                    selectedColor: AppColors.caramel,
                    backgroundColor: AppColors.espressoSoft.withValues(alpha: 0.5),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.espressoDeep : AppColors.tortilla,
                      fontWeight: FontWeight.w600,
                    ),
                    checkmarkColor: AppColors.espressoDeep,
                    side: BorderSide.none,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
    ];
  }

  Widget _buildBody() {
    if (_loading) return const HomeSkeleton();
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.caramel),
              const SizedBox(height: 16),
              Text(
                _networkError
                    ? 'Cannot reach BookVerse server'
                    : 'Could not load audiobooks',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.tortilla,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mutedText, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caramel,
                  foregroundColor: AppColors.espressoDeep,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'No audiobooks found',
          style: TextStyle(color: AppColors.mutedText, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.caramel,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ContentCard(
              item: item,
              compact: true,
              actionLabel: 'Play',
              onTap: () => requireLogin(context, () {
                Navigator.of(context).pushNamed(
                  BookDetailsScreen.routeName,
                  arguments: item,
                );
              }),
              onAction: () => _onAction(item),
            ),
          );
        },
      ),
    );
  }
}

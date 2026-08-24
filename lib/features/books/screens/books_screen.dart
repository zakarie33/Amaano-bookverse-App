import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/utils/content_filters.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/home_skeleton.dart';
import '../../cart/cart_provider.dart';
import '../models/content_model.dart';
import 'book_details_screen.dart';
import 'book_reader_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  static const String routeName = '/books';

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  bool _networkError = false;
  List<ContentModel> _books = [];
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
    _loadBooks();
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
      case 'latest':
        map['sort'] = 'latest';
        break;
      case 'featured':
        map['featured'] = '1';
        break;
    }
    return map.isEmpty ? null : map;
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
      _networkError = false;
    });
    try {
      final result = await _api.getBooks(query: _queryForFilter());
      _books = ContentFilters.booksOnly(_parseBooks(result.raw ?? {}));
      await LocalDbService.instance.cacheBooks(
        _books
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'author': e.author,
                'cover_url': e.coverUrl,
                'type': e.type,
                'price': e.price,
              },
            )
            .toList(),
      );
    } on ApiException catch (e) {
      try {
        final cached = await LocalDbService.instance.getCachedBooks();
        _books = cached
            .map(
              (row) => ContentModel(
                id: row['id'] as int? ?? 0,
                title: row['title'] as String? ?? '',
                author: row['author'] as String?,
                coverUrl: row['cover_url'] as String?,
                type: row['type'] as String?,
                price: (row['price'] as num?)?.toDouble(),
              ),
            )
            .toList();
        _error = _books.isEmpty ? e.message : null;
        _networkError = _books.isEmpty && e.isNetworkFailure;
      } catch (_) {
        _books = [];
        _error = e.message;
        _networkError = e.isNetworkFailure;
      }
    } catch (e) {
      try {
        final cached = await LocalDbService.instance.getCachedBooks();
        _books = cached
            .map(
              (row) => ContentModel(
                id: row['id'] as int? ?? 0,
                title: row['title'] as String? ?? '',
                author: row['author'] as String?,
                coverUrl: row['cover_url'] as String?,
                type: row['type'] as String?,
                price: (row['price'] as num?)?.toDouble(),
              ),
            )
            .toList();
        _error = _books.isEmpty ? e.toString() : null;
      } catch (_) {
        _books = [];
        _error = e.toString();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ContentModel> _parseBooks(dynamic data) {
    if (data is Map<String, dynamic>) {
      final list = data['books'] ?? data['data'] ?? data['items'];
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

  void _onBookAction(ContentModel book) {
    requireLogin(context, () {
      if (book.isFreeContent) {
        Navigator.of(context).pushNamed(
          BookReaderScreen.routeName,
          arguments: book,
        );
        return;
      }
      context.read<CartProvider>().addItem(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${book.title}" added to cart'),
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
              children: _buildBooksContent(context),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildBooksContent(context, showHeader: true),
              ),
            ),
    );
  }

  List<Widget> _buildBooksContent(BuildContext context, {bool showHeader = false}) {
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
                      'Books',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.tortilla,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Discover your next read',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 14,
                      ),
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
                  Icons.menu_book_rounded,
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
                  hintText: 'Search books…',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.8),
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.caramel),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.caramel),
                    onPressed: _loadBooks,
                  ),
                  filled: true,
                  fillColor: AppColors.espressoSoft.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _loadBooks(),
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
                      _loadBooks();
                    },
                    selectedColor: AppColors.caramel,
                    backgroundColor:
                        AppColors.espressoSoft.withValues(alpha: 0.5),
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.espressoDeep
                          : AppColors.tortilla,
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
    if (_loading) {
      return const HomeSkeleton();
    }
    if (_error != null && _books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 56, color: AppColors.caramel),
              const SizedBox(height: 16),
              Text(
                _networkError
                    ? 'Cannot reach BookVerse server'
                    : 'Could not load books',
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
                onPressed: _loadBooks,
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
    if (_books.isEmpty) {
      return const Center(
        child: Text(
          'No books found',
          style: TextStyle(color: AppColors.mutedText, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: AppColors.caramel,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ContentCard(
              item: book,
              compact: true,
              onTap: () => requireLogin(context, () {
                Navigator.of(context).pushNamed(
                  BookDetailsScreen.routeName,
                  arguments: book,
                );
              }),
              onAction: () => _onBookAction(book),
            ),
          );
        },
      ),
    );
  }
}

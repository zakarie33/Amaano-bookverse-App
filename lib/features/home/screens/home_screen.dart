import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';



import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

import '../../../core/services/api_service.dart';

import '../../../core/utils/auth_guard.dart';

import '../../../core/utils/content_filters.dart';

import '../../../core/widgets/bookverse_drawer.dart';
import '../../../core/widgets/bestseller_list_item.dart';
import '../../../core/widgets/featured_author_card.dart';
import '../../../core/widgets/home_greeting_header.dart';
import '../../../core/widgets/home_top_bar.dart';
import '../../../core/widgets/horizontal_book_section.dart';
import '../../../core/widgets/poster_slider.dart';
import '../../../core/widgets/carved_bottom_nav.dart';

import '../../../core/widgets/home_skeleton.dart';

import '../../audiobooks/screens/audiobooks_screen.dart';

import '../../books/models/content_model.dart';

import '../../books/screens/book_details_screen.dart';

import '../../books/screens/books_screen.dart';

import '../../audiobooks/screens/audio_player_screen.dart';
import '../../books/screens/book_reader_screen.dart';

import '../../cart/cart_provider.dart';

import '../../profile/screens/profile_screen.dart';
import '../models/announcement_model.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});



  static const String routeName = '/home';



  @override

  State<HomeScreen> createState() => _HomeScreenState();

}



class _HomeScreenState extends State<HomeScreen> {

  final _homeScrollController = ScrollController();

  int _tabIndex = 0;

  String _selectedCategory = 'All';

  bool _loadingHome = true;

  String? _homeError;
  bool _homeNetworkError = false;

  List<ContentModel> _books = [];

  List<ContentModel> _audiobooks = [];

  List<AnnouncementModel> _announcements = [];

  static const _homeCategories = ['All', 'Books', 'Audiobooks'];



  List<ContentModel> get _readableBooks => ContentFilters.booksOnly(_books);



  List<ContentModel> get _homeAudiobooks =>

      ContentFilters.mergeUniqueById(

        _audiobooks,

        ContentFilters.audiobooksOnly(_books),

      );



  List<ContentModel> get _newReleases {
    final books = List<ContentModel>.from(_readableBooks);
    books.sort((a, b) => b.id.compareTo(a.id));
    return books.take(10).toList();
  }

  List<ContentModel> get _basedOnReading {
    final featured = ContentFilters.featuredOnly(_books);
    final books = ContentFilters.booksOnly(featured);
    if (books.isNotEmpty) return books.take(10).toList();
    return _readableBooks.take(8).toList();
  }

  List<ContentModel> get _bestSellers {
    final sorted = List<ContentModel>.from(_readableBooks);
    sorted.sort((a, b) {
      final scoreA = (a.rating ?? 0) * (a.reviewCount ?? 1);
      final scoreB = (b.rating ?? 0) * (b.reviewCount ?? 1);
      return scoreB.compareTo(scoreA);
    });
    return sorted.take(10).toList();
  }

  List<AuthorSummary> get _featuredAuthors {
    final map = <String, List<ContentModel>>{};
    for (final book in _readableBooks) {
      final author = book.author?.trim();
      if (author == null || author.isEmpty) continue;
      map.putIfAbsent(author, () => []).add(book);
    }
    return map.entries
        .map((e) => AuthorSummary(name: e.key, books: e.value))
        .where((author) => author.bookCount >= 1)
        .take(10)
        .toList();
  }

  @override

  void initState() {

    super.initState();

    _loadHome();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applySystemChrome());

  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }



  Future<void> _loadHome() async {

    setState(() {

      _loadingHome = true;

      _homeError = null;
      _homeNetworkError = false;

    });

    try {

      final api = ApiService();

      // Primary feed: home.php (live AwardSpace host has home.php; books.php may be missing).
      final homeResult = await api.getHomeContent();
      final raw = homeResult.raw ?? {};

      var books = _parseList(raw['books'] ?? raw['sections']?['books']);
      var audiobooks =
          _parseList(raw['audiobooks'] ?? raw['sections']?['audiobooks']);
      var announcements = <AnnouncementModel>[];

      // Optional: full catalog when books.php is deployed on the server.
      try {
        final booksResult = await api.getBooks();
        final booksRaw = booksResult.raw ?? {};
        final fullBooks = _parseList(
          booksRaw['books'] ?? booksRaw['data'] ?? booksRaw['items'],
        );
        if (fullBooks.isNotEmpty) {
          books = fullBooks;
        }
      } catch (e) {
        debugPrint('Optional books.php enrichment failed: $e');
      }

      try {
        final announceResult = await api.getAnnouncements();
        final rawAnnounce = announceResult.raw ?? {};
        final list = rawAnnounce['announcements'] ?? rawAnnounce['data'];
        if (list is List) {
          announcements = list
              .whereType<Map>()
              .map((e) =>
                  AnnouncementModel.fromJson(Map<String, dynamic>.from(e)))
              .where((a) => a.title.isNotEmpty)
              .toList();
        }
      } catch (e) {
        debugPrint('Optional announcements load failed: $e');
      }

      if (!mounted) return;

      setState(() {

        _books = books;

        _audiobooks = audiobooks;

        _announcements = announcements;

        _loadingHome = false;

      });

    } on ApiException catch (e) {

      if (!mounted) return;

      setState(() {

        _loadingHome = false;

        _homeError = e.message;
        _homeNetworkError = e.isNetworkFailure;

      });

    } catch (e) {

      debugPrint('Home load failed: $e');

      if (!mounted) return;

      setState(() {

        _loadingHome = false;

        _homeError = e.toString();
        _homeNetworkError = false;

      });

    }

  }



  List<ContentModel> _parseList(dynamic list) {

    if (list is! List) return [];

    return list

        .whereType<Map>()

        .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))

        .toList();

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      drawer: BookVerseDrawer(
        currentIndex: _tabIndex,
        onSelectTab: (index) => setState(() => _tabIndex = index),
      ),
      body: _buildBody(),

      bottomNavigationBar: CarvedBottomNav(

        currentIndex: _tabIndex,

        onTap: _onTabSelected,

        style: _tabIndex == 0
            ? CarvedBottomNavStyle.home
            : CarvedBottomNavStyle.light,

      ),

    );

  }



  void _onTabSelected(int index) {

    setState(() => _tabIndex = index);
    _applySystemChrome();

  }

  void _applySystemChrome() {
    final lightNav = _tabIndex != 0;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor:
            lightNav ? AppColors.navLightBackground : AppColors.navBackground,
        systemNavigationBarIconBrightness:
            lightNav ? Brightness.dark : Brightness.light,
      ),
    );
  }

  Future<void> _openAnnouncement(AnnouncementModel item) async {
    final link = item.linkUrl?.trim();
    if (link == null || link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }



  Widget _buildBody() {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(
              title: _tabIndex == 0 ? null : _tabTitle(_tabIndex),
              onSearch: () => setState(() => _tabIndex = 1),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  String? _tabTitle(int index) {

    switch (index) {

      case 1:

        return 'Books';

      case 2:

        return 'Audiobooks';

      case 3:

        return 'Profile';

      default:

        return null;

    }

  }

  Widget _buildTabContent() {

    switch (_tabIndex) {

      case 0:

        return _buildHomeFeed();

      case 1:

        return const BooksScreen(embeddedInShell: true);

      case 2:

        return const AudiobooksScreen(embeddedInShell: true);

      case 3:

        return const ProfileScreen(embeddedInShell: true);

      default:

        return _buildHomeFeed();

    }

  }



  Widget _buildHomeFeed() {

    if (_loadingHome) {

      return const HomeSkeleton();

    }

    if (_homeError != null) {

      return _buildError();

    }

    return CustomScrollView(

      controller: _homeScrollController,

      physics: const BouncingScrollPhysics(),

      slivers: [

        if (_announcements.isNotEmpty)

          SliverToBoxAdapter(

            child: PosterSlider(

              items: _announcements,

              onTap: _openAnnouncement,

            ),

          ),

        const SliverToBoxAdapter(child: HomeGreetingHeader()),

        SliverToBoxAdapter(child: _buildCategoryChips()),

        if (_newReleases.isNotEmpty)
          _contentSection(
            'New Releases',
            _newReleases,
            seeAllTab: 1,
          ),

        if (_basedOnReading.isNotEmpty)
          _contentSection(
            'Based on Your Reading',
            _basedOnReading,
            seeAllTab: 1,
          ),

        if (_featuredAuthors.isNotEmpty)
          _authorSection('Featured Authors', _featuredAuthors),

        if (_bestSellers.isNotEmpty)
          _bestsellerSection('Bestsellers This Week', _bestSellers),

        _contentSection(
          'Audiobooks',
          _homeAudiobooks,
          actionLabel: 'Play',
          seeAllTab: 2,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 110)),

      ],

    );

  }



  Widget _buildError() {

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
              _homeNetworkError
                  ? 'Cannot reach BookVerse server'
                  : 'Could not load content',
              textAlign: TextAlign.center,
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              _homeError ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loadHome,
              child: const Text('Retry'),
            ),

          ],

        ),

      ),

    );

  }



  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            'Browse',
            style: AppTypography.sectionTitle.copyWith(fontSize: 16),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _homeCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = _homeCategories[index];
              final selected = _selectedCategory == label;
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = label),
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.chipInactive.withValues(alpha: 0.35),
                labelStyle: AppTypography.chip.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                checkmarkColor: AppColors.textPrimary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  void _openDetails(ContentModel item) {
    requireLogin(context, () {
      Navigator.of(context).pushNamed(
        BookDetailsScreen.routeName,
        arguments: item,
      );
    });
  }



  bool _showSection(String title) {

    if (_selectedCategory == 'All') return true;

    if (_selectedCategory == 'Books') {
      const bookSections = {
        'New Releases',
        'Based on Your Reading',
        'Featured Authors',
        'Bestsellers This Week',
      };
      return bookSections.contains(title);
    }

    if (_selectedCategory == 'Audiobooks') {

      return title == 'Audiobooks';

    }

    return true;

  }



  SliverToBoxAdapter _contentSection(
    String title,
    List<ContentModel> items, {
    String? actionLabel,
    int? seeAllTab,
  }) {
    if (!_showSection(title)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: HorizontalBookSection(
        title: title,
        items: items,
        actionLabel: actionLabel,
        onSeeAll: seeAllTab == null
            ? null
            : () => setState(() => _tabIndex = seeAllTab),
        onItemTap: _openDetails,
        onItemAction: (item) => _onSectionAction(item, actionLabel: actionLabel),
      ),
    );
  }

  SliverToBoxAdapter _bestsellerSection(
    String title,
    List<ContentModel> items,
  ) {
    if (!_showSection(title)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: BestsellersRankedSection(
        title: title,
        items: items,
        onSeeAll: () => setState(() => _tabIndex = 1),
        onItemTap: _openDetails,
      ),
    );
  }

  SliverToBoxAdapter _authorSection(
    String title,
    List<AuthorSummary> authors,
  ) {
    if (!_showSection(title)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: FeaturedAuthorsSection(
        title: title,
        authors: authors,
        onSeeAll: () => setState(() => _tabIndex = 1),
        onAuthorTap: (author) {
          if (author.books.isEmpty) return;
          _openDetails(author.books.first);
        },
      ),
    );
  }

  void _onSectionAction(ContentModel item, {String? actionLabel}) {
    requireLogin(context, () {
      if (actionLabel == 'Play') {
        Navigator.of(context).pushNamed(
          AudioPlayerScreen.routeName,
          arguments: item,
        );
        return;
      }
      if (item.isFreeContent) {
        Navigator.of(context).pushNamed(
          BookReaderScreen.routeName,
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

}



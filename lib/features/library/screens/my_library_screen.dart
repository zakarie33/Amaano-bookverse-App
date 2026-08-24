import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../../core/constants/api_constants.dart';

import '../../../core/constants/app_colors.dart';

import '../../../core/services/api_service.dart';

import '../../../core/services/auth_service.dart';

import '../../../core/utils/content_filters.dart';

import '../../../core/widgets/content_card.dart';

import '../../auth/screens/login_screen.dart';

import '../../audiobooks/screens/audio_player_screen.dart';

import '../../books/models/content_model.dart';

import '../../books/screens/book_details_screen.dart';

import '../../books/screens/book_reader_screen.dart';

import 'my_purchases_screen.dart';



class MyLibraryScreen extends StatefulWidget {

  const MyLibraryScreen({super.key});



  static const String routeName = '/library';



  @override

  State<MyLibraryScreen> createState() => _MyLibraryScreenState();

}



class _MyLibraryScreenState extends State<MyLibraryScreen>

    with SingleTickerProviderStateMixin {

  late final TabController _tabs;

  bool _loading = true;

  String? _error;

  List<ContentModel> _books = [];

  List<ContentModel> _audiobooks = [];



  @override

  void initState() {

    super.initState();

    _tabs = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());

  }



  @override

  void dispose() {

    _tabs.dispose();

    super.dispose();

  }



  Future<void> _load() async {

    setState(() {

      _loading = true;

      _error = null;

    });

    try {

      final data = await ApiService().get(ApiConstants.userLibrary);

      final lib = data is Map ? data['library'] : null;

      if (!mounted) return;

      setState(() {

        _books = ContentFilters.booksOnly(_parse(lib?['books']));

        _audiobooks = ContentFilters.audiobooksOnly(

          ContentFilters.mergeUniqueById(

            _parse(lib?['audiobooks']),

            _parse(lib?['books']),

          ),

        );

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



  List<ContentModel> _parse(dynamic list) {

    if (list is! List) return [];

    return list

        .whereType<Map>()

        .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))

        .toList();

  }



  void _openReader(ContentModel item) {

    if (item.hasAudio && !item.canRead) {

      Navigator.of(context).pushNamed(

        AudioPlayerScreen.routeName,

        arguments: item,

      );

      return;

    }

    Navigator.of(context).pushNamed(

      BookReaderScreen.routeName,

      arguments: item,

    );

  }



  @override

  Widget build(BuildContext context) {

    final auth = context.watch<AuthService>();

    if (!auth.isLoggedIn) {

      return Container(

        color: AppColors.espresso,

        child: SafeArea(

          child: Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Text(

                  'Sign in to access your library',

                  style: TextStyle(color: AppColors.mutedText),

                ),

                const SizedBox(height: 16),

                ElevatedButton(

                  onPressed: () =>

                      Navigator.of(context).pushNamed(LoginScreen.routeName),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppColors.caramel,

                    foregroundColor: AppColors.espressoDeep,

                  ),

                  child: const Text('Login'),

                ),

              ],

            ),

          ),

        ),

      );

    }



    return Container(

      color: AppColors.espresso,

      child: SafeArea(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Padding(

              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

              child: Row(

                children: [

                  Expanded(

                    child: Text(

                      'My Library',

                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                            color: AppColors.tortilla,

                            fontWeight: FontWeight.w700,

                          ),

                    ),

                  ),

                  TextButton(

                    onPressed: () => Navigator.of(context)

                        .pushNamed(MyPurchasesScreen.routeName),

                    child: const Text('Pending purchases'),

                  ),

                ],

              ),

            ),

            TabBar(

              controller: _tabs,

              indicatorColor: AppColors.caramel,

              labelColor: AppColors.tortilla,

              unselectedLabelColor: AppColors.mutedText,

              tabs: const [

                Tab(text: 'Books'),

                Tab(text: 'Audiobooks'),

              ],

            ),

            Expanded(

              child: _loading

                  ? const Center(

                      child: CircularProgressIndicator(color: AppColors.caramel),

                    )

                  : _error != null

                      ? Center(

                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              Text(_error!,

                                  style: const TextStyle(color: AppColors.danger)),

                              TextButton(onPressed: _load, child: const Text('Retry')),

                            ],

                          ),

                        )

                      : TabBarView(

                          controller: _tabs,

                          children: [

                            _buildList(_books, emptyMessage:

                                'No approved books in your library yet.'),

                            _buildList(

                              _audiobooks,

                              emptyMessage:

                                  'No approved audiobooks in your library yet.',

                              playMode: true,

                            ),

                          ],

                        ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildList(

    List<ContentModel> items, {

    required String emptyMessage,

    bool playMode = false,

  }) {

    if (items.isEmpty) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(32),

          child: Text(

            emptyMessage,

            textAlign: TextAlign.center,

            style: const TextStyle(color: AppColors.mutedText, height: 1.5),

          ),

        ),

      );

    }



    return RefreshIndicator(

      onRefresh: _load,

      color: AppColors.caramel,

      child: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: items.length,

        itemBuilder: (context, index) {

          final item = items[index];

          return Padding(

            padding: const EdgeInsets.only(bottom: 16),

            child: ContentCard(

              item: item,

              compact: true,

              actionLabel: playMode ? 'Play' : 'Read in App',

              onTap: () => Navigator.of(context).pushNamed(

                BookDetailsScreen.routeName,

                arguments: item,

              ),

              onAction: () {

                if (playMode) {

                  Navigator.of(context).pushNamed(

                    AudioPlayerScreen.routeName,

                    arguments: item,

                  );

                } else {

                  _openReader(item);

                }

              },

            ),

          );

        },

      ),

    );

  }

}



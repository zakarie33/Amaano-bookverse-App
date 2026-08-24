import '../../features/books/models/content_model.dart';

class UserLibraryModel {
  const UserLibraryModel({
    this.books = const [],
    this.audiobooks = const [],
    this.research = const [],
    this.articles = const [],
  });

  final List<ContentModel> books;
  final List<ContentModel> audiobooks;
  final List<ContentModel> research;
  final List<ContentModel> articles;

  bool get isEmpty =>
      books.isEmpty &&
      audiobooks.isEmpty &&
      research.isEmpty &&
      articles.isEmpty;

  factory UserLibraryModel.fromJson(Map<String, dynamic> json) {
    final lib = json['library'];
    if (lib is! Map) {
      return const UserLibraryModel();
    }
    return UserLibraryModel(
      books: _parseList(lib['books']),
      audiobooks: _parseList(lib['audiobooks']),
      research: _parseList(lib['research']),
      articles: _parseList(lib['articles']),
    );
  }

  static List<ContentModel> _parseList(dynamic list) {
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

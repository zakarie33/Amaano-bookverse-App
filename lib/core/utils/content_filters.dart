import '../../features/books/models/content_model.dart';

class ContentFilters {
  ContentFilters._();

  static bool isAudiobookType(ContentModel item) {
    final t = item.type?.toLowerCase() ?? '';
    return t == 'audiobook' || t == 'audio';
  }

  static bool appearsInBooks(ContentModel item) => !isAudiobookType(item);

  static bool appearsInAudiobooks(ContentModel item) =>
      isAudiobookType(item) || item.hasAudio;

  static List<ContentModel> booksOnly(Iterable<ContentModel> items) =>
      items.where(appearsInBooks).toList();

  static List<ContentModel> audiobooksOnly(Iterable<ContentModel> items) =>
      items.where(appearsInAudiobooks).toList();

  static List<ContentModel> featuredOnly(Iterable<ContentModel> items) =>
      items.where((i) => i.featured == true).toList();

  static List<ContentModel> mergeUniqueById(
    Iterable<ContentModel> a,
    Iterable<ContentModel> b,
  ) {
    final map = <int, ContentModel>{};
    for (final item in [...a, ...b]) {
      map[item.id] = item;
    }
    return map.values.toList();
  }
}

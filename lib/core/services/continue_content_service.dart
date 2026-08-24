import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/books/models/content_model.dart';

/// Tracks continue + history for read/listen on home.
class ContinueContentService {
  ContinueContentService._();
  static final ContinueContentService instance = ContinueContentService._();

  static const _readPrefix = 'continue_read_';
  static const _listenPrefix = 'continue_listen_';
  static const _historyReadPrefix = 'history_read_';
  static const _historyListenPrefix = 'history_listen_';
  static const _maxHistory = 12;

  String _readKey(String userId) => '$_readPrefix$userId';
  String _listenKey(String userId) => '$_listenPrefix$userId';
  String _historyReadKey(String userId) => '$_historyReadPrefix$userId';
  String _historyListenKey(String userId) => '$_historyListenPrefix$userId';

  Map<String, dynamic> _toMap(ContentModel item) => {
        'id': item.id,
        'title': item.title,
        'author': item.author,
        'cover_url': item.coverUrl,
        'type': item.type,
        'price': item.price,
        'has_access': item.hasAccess,
        'is_paid': item.isPaid,
        'read_url': item.readUrl,
        'listen_url': item.listenUrl,
        'file_url': item.fileUrl,
        'audio_url': item.audioUrl,
      };

  ContentModel? _fromStored(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map) {
        return ContentModel.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (_) {}
    return null;
  }

  List<ContentModel> _listFromStored(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveHistory(String key, ContentModel content) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _listFromStored(prefs.getString(key));
    list.removeWhere((e) => e.id == content.id);
    list.insert(0, content);
    if (list.length > _maxHistory) {
      list.removeRange(_maxHistory, list.length);
    }
    await prefs.setString(
      key,
      jsonEncode(list.map(_toMap).toList()),
    );
  }

  Future<void> saveReading(String userId, ContentModel content) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readKey(userId), jsonEncode(_toMap(content)));
    await _saveHistory(_historyReadKey(userId), content);
  }

  Future<void> saveListening(String userId, ContentModel content) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_listenKey(userId), jsonEncode(_toMap(content)));
    await _saveHistory(_historyListenKey(userId), content);
  }

  Future<ContentModel?> getContinueReading(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return _fromStored(prefs.getString(_readKey(userId)));
  }

  Future<ContentModel?> getContinueListening(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return _fromStored(prefs.getString(_listenKey(userId)));
  }

  Future<List<ContentModel>> getReadingHistory(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    return _listFromStored(prefs.getString(_historyReadKey(userId)));
  }

  Future<List<ContentModel>> getListeningHistory(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    return _listFromStored(prefs.getString(_historyListenKey(userId)));
  }
}

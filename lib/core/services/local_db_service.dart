import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite cache for offline reads (not the primary data store).
class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  Database? _db;

  static const String _dbName = 'bookverse_cache.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_books (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT,
            cover_url TEXT,
            type TEXT,
            price REAL,
            payload TEXT,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_home (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> cacheBooks(List<Map<String, dynamic>> rows) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('cached_books');
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final row in rows) {
      batch.insert('cached_books', {
        'id': row['id'],
        'title': row['title'] ?? '',
        'author': row['author'],
        'cover_url': row['cover_url'] ?? row['cover'],
        'type': row['type'],
        'price': row['price'],
        'payload': row.toString(),
        'updated_at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> getCachedBooks() async {
    final db = await database;
    return db.query('cached_books', orderBy: 'title ASC');
  }

  Future<void> cacheHomePayload(String payload) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'cached_home',
      {'id': 1, 'payload': payload, 'updated_at': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

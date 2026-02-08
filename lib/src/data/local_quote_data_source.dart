import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/quote_item.dart';

class LocalQuoteDataSource {
  static const String _table = 'quotes';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) {
      return _db!;
    }

    final String dbPath = await getDatabasesPath();
    final String fullPath = p.join(dbPath, 'haocihaoju_quotes.db');

    _db = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            quote TEXT NOT NULL,
            analysis TEXT NOT NULL,
            style_notes TEXT NOT NULL,
            article_text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<List<QuoteItem>> getQuotes() async {
    final Database db = await _database;
    final List<Map<String, Object?>> rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map(QuoteItem.fromMap).toList();
  }

  Future<void> addQuote(QuoteItem item) async {
    final Database db = await _database;
    await db.insert(
      _table,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteQuote(String id) async {
    final Database db = await _database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}

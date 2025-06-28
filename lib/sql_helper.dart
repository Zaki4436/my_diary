import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  // Open database
  static Future<Database> _db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'diary.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            feeling TEXT,
            description TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // Insert new entry
  static Future<void> insertEntry(String feeling, String description) async {
    final db = await _db();
    await db.insert(
      'entries',
      {
        'feeling': feeling,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all entries (ordered by newest first)
  static Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await _db();
    return db.query(
      'entries',
      orderBy: 'createdAt DESC',
    );
  }

  // Update existing entry
  static Future<void> updateEntry(int id, String feeling, String description) async {
    final db = await _db();
    await db.update(
      'entries',
      {
        'feeling': feeling,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteEntry(int id) async {
    final db = await _db();
    await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

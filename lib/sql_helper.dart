import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static Future<Database> _db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'diary.db'),
      version: 2,
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE entries ADD COLUMN feeling TEXT');
          await db.execute('ALTER TABLE entries ADD COLUMN description TEXT');
          await db.execute('ALTER TABLE entries ADD COLUMN createdAt TEXT');
        }
      },
    );
  }

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

  static Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await _db();
    return db.query(
      'entries',
      orderBy: 'createdAt DESC',
    );
  }

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
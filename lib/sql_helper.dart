import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class SQLHelper {
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

  static Future<void> insertEntry(String feeling, String description) async {
    final db = await _db();
    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now); // e.g. 30 September 2004, 4:18 AM
    await db.insert(
      'entries',
      {
        'feeling': feeling,
        'description': description,
        'createdAt': formatted,
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
    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now);
    await db.update(
      'entries',
      {
        'feeling': feeling,
        'description': description,
        'createdAt': formatted,
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
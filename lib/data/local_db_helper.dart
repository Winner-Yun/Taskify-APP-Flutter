import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDbHelper {
  static final LocalDbHelper _instance = LocalDbHelper._internal();
  factory LocalDbHelper() => _instance;
  LocalDbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_settings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY,
            isDarkMode INTEGER,
            lastNameChange INTEGER
          )
        ''');
        // Insert default row
        await db.insert('settings', {
          'id': 1,
          'isDarkMode': 0, // 0 = false, 1 = true
          'lastNameChange': 0,
        });
      },
    );
  }

  // ================= GETTERS =================
  Future<bool> getDarkMode() async {
    final db = await database;
    final res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return res.first['isDarkMode'] == 1;
    }
    return false;
  }

  Future<int> getLastNameChangeTime() async {
    final db = await database;
    final res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return res.first['lastNameChange'] as int;
    }
    return 0;
  }

  // ================= SETTERS =================
  Future<void> setDarkMode(bool value) async {
    final db = await database;
    await db.update(
      'settings',
      {'isDarkMode': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> setLastNameChangeTime(int timestamp) async {
    final db = await database;
    await db.update(
      'settings',
      {'lastNameChange': timestamp},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}

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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY,
            isDarkMode INTEGER,
            lastNameChange INTEGER,
            isRoutineMode INTEGER DEFAULT 0,
            languageCode TEXT DEFAULT 'en' 
          )
        ''');
        await db.insert('settings', {
          'id': 1,
          'isDarkMode': 0,
          'lastNameChange': 0,
          'isRoutineMode': 0,
          'languageCode': 'en', // Default English
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE settings ADD COLUMN isRoutineMode INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE settings ADD COLUMN languageCode TEXT DEFAULT 'en'",
          );
        }
      },
    );
  }

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

  Future<int> getRoutineMode() async {
    final db = await database;
    final res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return res.first['isRoutineMode'] as int;
    }
    return 0;
  }

  Future<String> getLanguage() async {
    final db = await database;
    final res = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty && res.first['languageCode'] != null) {
      return res.first['languageCode'] as String;
    }
    return 'en'; // Default
  }

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

  Future<void> setRoutineMode(int value) async {
    final db = await database;
    await db.update(
      'settings',
      {'isRoutineMode': value},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> setLanguage(String langCode) async {
    final db = await database;
    await db.update(
      'settings',
      {'languageCode': langCode},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}

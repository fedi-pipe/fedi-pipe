import 'package:sqflite/sqflite.dart';

class PersistentBaseRepository {
  static const dbName = 'fedi-pipe.db';

  static const draftsTable = 'drafts';
  static const authTable = 'auth';

  Future<Database> open() async {
    final databasePath = await getDatabasesPath();
    String path = '$databasePath/$dbName';

    return openDatabase(path, version: 2, onCreate: (db, version) async {
      await createTable(db);
    }, onUpgrade: onUpgrade);
  }

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $draftsTable (
        id INTEGER PRIMARY KEY,
        content TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await createTable(db);
    }

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $authTable (
          id INTEGER PRIMARY KEY,
          active BOOLEAN DEFAULT 0,
          instance TEXT NOT NULL,
          access_token TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }
}

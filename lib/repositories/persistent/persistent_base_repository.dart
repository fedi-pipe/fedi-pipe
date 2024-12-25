import 'package:sqflite/sqflite.dart';

class PersistentBaseRepository {
  static const dbName = 'fedi-pipe.db';

  static const draftsTable = 'drafts';

  Future<Database> open() async {
    final databasePath = await getDatabasesPath();
    String path = '$databasePath/$dbName';

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await createTable(db);
    });
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
}

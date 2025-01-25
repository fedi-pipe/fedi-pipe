import 'package:fedi_pipe/models/auth.dart';
import 'package:fedi_pipe/repositories/persistent/persistent_base_repository.dart';

class AuthRepository extends PersistentBaseRepository {
  static const authTable = 'auth';

  Future<List<Auth>> availableAccounts() async {
    final db = await open();
    final auths = await db.query(authTable);
    await db.close();

    final result = auths.map((auth) {
      final id = auth['id'] as int;
      final instance = auth['instance'] as String;
      final accessToken = auth['access_token'] as String;

      return Auth(id: id, instance: instance, accessToken: accessToken);
    }).toList();

    return result;
  }

  Future<void> saveAuth(String instance, String accessToken) async {
    final db = await open();
    final auth = await db.insert(authTable, {
      'instance': instance,
      'access_token': accessToken,
    });

    await setActiveAuth(auth);

    await db.close();
  }

  Future<void> deleteAuth(int id) async {
    final db = await open();
    await db.delete(authTable, where: 'id = ?', whereArgs: [id]);
    await db.close();
  }

  Future<void> setActiveAuth(int id) async {
    final db = await open();
    await db.update(authTable, {'active': 0});
    await db.update(authTable, {'active': 1}, where: 'id = ?', whereArgs: [id]);
    await db.close();
  }

  Future<Auth?> getAuth() async {
    final db = await open();
    // if table not exists, create it
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $authTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        instance TEXT NOT NULL,
        access_token TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 0
      )
    ''');
    final auth = await db.query(authTable, where: 'active = 1');
    await db.close();

    final authData = auth.isNotEmpty ? auth.first : null;

    if (authData == null) {
      return null;
    }
    final instance = authData['instance'] as String;
    final accessToken = authData['access_token'] as String;

    final result = Auth(instance: instance, accessToken: accessToken);

    return result;
  }
}

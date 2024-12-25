import 'package:fedi_pipe/models/auth.dart';
import 'package:fedi_pipe/repositories/persistent/persistent_base_repository.dart';

class AuthRepository extends PersistentBaseRepository {
  static const authTable = 'auth';

  Future<void> saveAuth(String instance, String accessToken) async {
    final db = await open();
    final auth = await db.insert(authTable, {
      'instance': instance,
      'access_token': accessToken,
    });

    await setActiveAuth(auth);

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

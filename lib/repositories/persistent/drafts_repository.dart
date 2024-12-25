import 'package:fedi_pipe/repositories/persistent/persistent_base_repository.dart';

class DraftsRepository extends PersistentBaseRepository {
  static const draftsTable = 'drafts';

  Future<void> createDraft(String content) async {
    final db = await open();
    await db.insert(draftsTable, {'content': content});
    await db.close();
  }

  Future<List<Map<String, dynamic>>> getDrafts() async {
    final db = await open();
    final drafts = await db.query(draftsTable);
    await db.close();
    return drafts;
  }

  Future<void> deleteDraft(int id) async {
    final db = await open();
    await db.delete(draftsTable, where: 'id = ?', whereArgs: [id]);
    await db.close();
  }
}

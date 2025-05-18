import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

class MastodonAccountRepository extends MastodonBaseRepository {
  static Future<MastodonAccountModel> lookUpAccount(String acct) async {
    try {
      if (acct.startsWith('@')) {
        final account = await _tryLookUpRemoteAccount(acct);
        if (account != null) {
          return account;
        }
      }
    } catch (e) {
      print(e);
    }

    final localAccount = await _tryLookUpLocalAccount(acct);
    return localAccount;
  }

  static Future<dynamic> _tryLookUpRemoteAccount(String acct) async {
    try {
      final response = await Client.get('/api/v1/accounts/lookup', queryParameters: {'acct': acct.substring(1)});
      final json = jsonDecode(response.body);
      final account = MastodonAccountModel.fromJson(json);

      return account;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> _tryLookUpLocalAccount(String acct) async {
    final handle = acct.substring(1).split('@')[0];
    try {
      final response = await Client.get('/api/v1/accounts/lookup', queryParameters: {'acct': handle});
      final json = jsonDecode(response.body);
      final account = MastodonAccountModel.fromJson(json);

      return account;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<MastodonAccountModel>> searchAccounts(String query) async {
    final response = await Client.get('/api/v1/accounts/search', queryParameters: {'q': query});
    final json = jsonDecode(response.body);
    final accounts = (json as List).map((account) => MastodonAccountModel.fromJson(account)).toList();

    return accounts;
  }
}

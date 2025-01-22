import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

class MastodonAccountRepository extends MastodonBaseRepository {
  static Future<MastodonAccountModel> lookUpAccount(String acct) async {
    final response = await Client.get('/api/v1/accounts/lookup', queryParameters: {'acct': acct});
    final json = jsonDecode(response.body);
    final account = MastodonAccountModel.fromJson(json);

    return account;
  }

  static Future<List<MastodonAccountModel>> searchAccounts(String query) async {
    final response = await Client.get('/api/v1/accounts/search', queryParameters: {'q': query});
    final json = jsonDecode(response.body);
    final accounts = (json as List).map((account) => MastodonAccountModel.fromJson(account)).toList();

    return accounts;
  }
}

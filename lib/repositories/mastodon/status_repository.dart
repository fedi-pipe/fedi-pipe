import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

class MastodonStatusRepository extends MastodonBaseRepository {
  static Future<List<MastodonStatusModel>> fetchStatuses() async {
    final response = await Client.get('/api/v1/timelines/public');
    final json = jsonDecode(response.body);
    final statuses = MastodonStatusModel.fromJsonList(json);

    return statuses;
  }
}

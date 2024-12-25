import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

class MastodonStatusRepository extends MastodonBaseRepository {
  static Future<List<MastodonStatusModel>> fetchStatuses({String? previousId, String? nextId}) async {
    final queryParameters = <String, String>{};
    if (previousId != null) {
      queryParameters['max_id'] = previousId;
    } else if (nextId != null) {
      queryParameters['min_id'] = nextId;
    }

    final response = await Client.get('/api/v1/timelines/public', queryParameters: queryParameters);
    print("========");
    print(response);
    print(response.headers);
    print(response.body);
    print("========");
    final json = jsonDecode(response.body);
    final statuses = MastodonStatusModel.fromJsonList(json);

    return statuses;
  }

  static Future<MastodonStatusModel> postStatus(String status) async {
    final response = await Client.post('/api/v1/statuses', {'status': status});
    final json = jsonDecode(response.body);
    final newStatus = MastodonStatusModel.fromJson(json);

    return newStatus;
  }
}

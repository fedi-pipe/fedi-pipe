import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

enum FeedType { public, home, local }

class MastodonStatusRepository extends MastodonBaseRepository {
  static Future<MastodonStatusModel> fetchStatus(String id) async {
    final response = await Client.get('/api/v1/statuses/$id');
    final json = jsonDecode(response.body);
    print(json);
    final status = MastodonStatusModel.fromJson(json);

    return status;
  }

  static Future<List<MastodonStatusModel>> fetchStatuses(
      {String? previousId, String? nextId, FeedType feedType = FeedType.home}) async {
    final queryParameters = <String, String>{};
    if (previousId != null) {
      queryParameters['max_id'] = previousId;
    } else if (nextId != null) {
      queryParameters['min_id'] = nextId;
    }

    final path = switch (feedType) {
      FeedType.public => '/api/v1/timelines/public',
      FeedType.home => '/api/v1/timelines/home',
      FeedType.local => '/api/v1/timelines/public',
    };

    if (feedType == FeedType.local) {
      queryParameters['local'] = 'true';
    }

    final response = await Client.get(path, queryParameters: queryParameters);
    final json = jsonDecode(response.body);
    final statuses = MastodonStatusModel.fromJsonList(json);

    return statuses;
  }

  static Future<void> postStatus(String status) async {
    final body = {
      'status': status,
      'visibility': 'unlisted',
      'media_ids': [],
      'sensitive': false,
      'spoiler_text': '',
      'poll': null,
      'language': 'ko',
    };
    final response = await Client.post('/api/v1/statuses', body);
  }
}

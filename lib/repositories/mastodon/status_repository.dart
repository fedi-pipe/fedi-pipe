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

  static Future<List<MastodonStatusModel>> fetchBookmarks() async {
    final response = await Client.get('/api/v1/bookmarks');
    final json = jsonDecode(response.body);
    print(json);
    final statuses = MastodonStatusModel.fromJsonList(json);

    return statuses;
  }

  static Future<List<MastodonStatusModel>> fetchFavourites() async {
    final response = await Client.get('/api/v1/favourites');
    final json = jsonDecode(response.body);
    final statuses = MastodonStatusModel.fromJsonList(json);

    return statuses;
  }

  static Future<List<MastodonStatusModel>> fetchCollection(collectionType) async {
    if (collectionType == 'favourites') {
      return fetchFavourites();
    } else if (collectionType == 'bookmarks') {
      return fetchBookmarks();
    }

    return [];
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

  static Future<void> replyToStatus(String statusId, String content) async {
    await postStatus(content, additionalPayload: {
      'in_reply_to_id': statusId,
    });
  }

  static Future<void> postStatus(String status, {Map<String, dynamic>? additionalPayload}) async {
    final body = {
      'status': status,
      'visibility': 'unlisted',
      'media_ids': [],
      'sensitive': false,
      'spoiler_text': '',
      'poll': null,
      'language': 'ko',
      ...?additionalPayload,
    };
    final response = await Client.post('/api/v1/statuses', body);
  }

  static Future<void> bookmarkStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/bookmark', {});
  }

  static Future<void> unbookmarkStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/unbookmark', {});
  }
}

import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

enum FeedType { public, home, local }

/*  Example Link header:
  link: <https://social.silicon.moe/api/v2/notifications?exclude_types%5B%5D=follow_request&grouped_types%5B%5D=favourite&grouped_types%5B%5D=reblog&grouped_types%5B%5D=follow&max_id=172698>; rel="next", <https://social.silicon.moe/api/v2/notifications?exclude_types%5B%5D=follow_request&grouped_types%5B%5D=favourite&grouped_types%5B%5D=reblog&grouped_types%5B%5D=follow&min_id=173515>; rel="prev"
*/

class MastodonStatusRepository extends MastodonBaseRepository {
  static Future<MastodonStatusModel> fetchStatus(String id) async {
    final response = await Client.get('/api/v1/statuses/$id');
    final json = jsonDecode(response.body);
    print(json);
    final status = MastodonStatusModel.fromJson(json);

    return status;
  }

  static Future<PaginationResult<MastodonStatusModel>> fetchBookmarks({
    String? previousId,
    String? nextId,
  }) async {
    final additionalQueryParameters = <String, String>{};
    if (previousId != null) {
      additionalQueryParameters['max_id'] = previousId;
    } else if (nextId != null) {
      additionalQueryParameters['min_id'] = nextId;
    }
    final response = await Client.get('/api/v1/bookmarks', queryParameters: additionalQueryParameters);
    final json = jsonDecode(response.body);
    print(json);
    final statuses = MastodonStatusModel.fromJsonList(json);

    final linkHeader = response.headers['link'];
    var pagination = PaginationResult<MastodonStatusModel>.parseLinkHeader(linkHeader!);
    pagination.items = statuses;

    return pagination;
  }

  static Future<PaginationResult<MastodonStatusModel>> fetchFavourites({
    String? perviousId,
    String? nextId,
  }) async {
    final additionalQueryParameters = <String, String>{
      if (perviousId != null) 'max_id': perviousId,
      if (nextId != null) 'min_id': nextId,
    };
    final response = await Client.get('/api/v1/favourites', queryParameters: additionalQueryParameters);
    final json = jsonDecode(response.body);
    final statuses = MastodonStatusModel.fromJsonList(json);

    final linkHeader = response.headers['link'];
    if (linkHeader == null) {
      return PaginationResult(items: statuses);
    }
    var pagination = PaginationResult<MastodonStatusModel>.parseLinkHeader(linkHeader!);
    pagination.items = statuses;

    return pagination;
  }

  static Future<PaginationResult<MastodonStatusModel>> fetchCollection(
    collectionType, {
    String? previousId,
    String? nextId,
  }) async {
    if (collectionType == 'favourites') {
      return fetchFavourites(
        perviousId: previousId,
        nextId: nextId,
      );
    } else if (collectionType == 'bookmarks') {
      return fetchBookmarks(
        previousId: previousId,
        nextId: nextId,
      );
    }

    return PaginationResult();
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

  static Future<void> favouriteStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/favourite', {});
  }

  static Future<void> unfavouriteStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/unfavourite', {});
  }

  static Future<void> bookmarkStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/bookmark', {});
  }

  static Future<void> unbookmarkStatus(String statusId) async {
    await Client.post('/api/v1/statuses/$statusId/unbookmark', {});
  }
}

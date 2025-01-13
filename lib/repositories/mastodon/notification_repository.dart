import 'dart:convert';

import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/mastodon_base_repository.dart';

/*  Example Link header:
  link: <https://social.silicon.moe/api/v2/notifications?exclude_types%5B%5D=follow_request&grouped_types%5B%5D=favourite&grouped_types%5B%5D=reblog&grouped_types%5B%5D=follow&max_id=172698>; rel="next", <https://social.silicon.moe/api/v2/notifications?exclude_types%5B%5D=follow_request&grouped_types%5B%5D=favourite&grouped_types%5B%5D=reblog&grouped_types%5B%5D=follow&min_id=173515>; rel="prev"
*/

class MastodonNotificationRepository extends MastodonBaseRepository {
  static Future<MastodonNotificationModel> fetchNotification(String id) async {
    final response = await Client.get('/api/v1/notifications/$id');
    final json = jsonDecode(response.body);
    final status = MastodonNotificationModel.fromJson(json);

    return status;
  }

  static Future<List<MastodonNotificationModel>> fetchNotifications(
      {String? previousId, String? nextId, NotificationFeedType feedType = NotificationFeedType.all}) async {
    final queryParameters = <String, String>{};
    if (previousId != null) {
      queryParameters['max_id'] = previousId;
    } else if (nextId != null) {
      queryParameters['min_id'] = nextId;
    }

    final path = "/api/v1/notifications";
    switch (feedType) {
      case NotificationFeedType.all:
        break;
      case NotificationFeedType.mention:
        queryParameters['types[]'] = 'mention';
        break;
      case NotificationFeedType.favourite:
        queryParameters['types[]'] = 'favourite';
        break;
      case NotificationFeedType.reblog:
        queryParameters['types[]'] = 'reblog';
        break;
      case NotificationFeedType.follow:
        queryParameters['types[]'] = 'follow';
        break;
    }

    final response = await Client.get(path, queryParameters: queryParameters);
    final json = jsonDecode(response.body);
    final notifications = MastodonNotificationModel.fromJsonList(json);

    return notifications;
  }
}

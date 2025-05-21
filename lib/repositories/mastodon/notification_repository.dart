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

  static Future<List<MastodonNotificationModel>> fetchNotifications({
    String? previousId,
    String? nextId,
    NotificationFeedType feedType = NotificationFeedType.all, // Keep for potential filtering later
    int limit = 40, // Default limit, can be overridden
    List<String> excludeTypes = const ['follow_request'], // Default exclusion
  }) async {
    final queryParameters = <String, String>{};
    queryParameters['limit'] = limit.toString();

    if (previousId != null) {
      queryParameters['max_id'] = previousId;
    } else if (nextId != null) {
      queryParameters['min_id'] = nextId;
    }

    // Handle exclude_types
    String excludeTypesQuery = excludeTypes.map((type) => 'exclude_types[]=${Uri.encodeComponent(type)}').join('&');

    String path = "/api/v1/notifications";
    String queryString = Uri(queryParameters: queryParameters).query;
    if (queryString.isNotEmpty && excludeTypesQuery.isNotEmpty) {
      queryString += '&' + excludeTypesQuery;
    } else if (excludeTypesQuery.isNotEmpty) {
      queryString = excludeTypesQuery;
    }
    
    if (queryString.isNotEmpty) {
        path += '?$queryString';
    }

    // Make the GET request (path already includes query parameters)
    final response = await Client.get(path); // Query parameters already in path

    final json = jsonDecode(response.body);
    if (json is! List) { // Add type check for safety
        print("Unexpected API response format: $json");
        return [];
    }
    final notifications = MastodonNotificationModel.fromJsonList(json);

    return notifications;
  }
}

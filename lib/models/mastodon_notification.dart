// GET https://mastodon.social/api/v1/notifications
/*

[
  {
    "id": "34975861",
    "type": "mention",
    "created_at": "2019-11-23T07:49:02.064Z",
    "account": {
      "id": "971724",
      "username": "zsc",
      "acct": "zsc",
      // ...
    },
    "status": {
      "id": "103186126728896492",
      "created_at": "2019-11-23T07:49:01.940Z",
      "in_reply_to_id": "103186038209478945",
      "in_reply_to_account_id": "14715",
      // ...
      "content": "<p><span class=\"h-card\"><a href=\"https://mastodon.social/@trwnh\" class=\"u-url mention\">@<span>trwnh</span></a></span> sup!</p>",
      // ...
      "account": {
        "id": "971724",
        "username": "zsc",
        "acct": "zsc",
        // ...
      },
      // ...
      "mentions": [
        {
          "id": "14715",
          "username": "trwnh",
          "url": "https://mastodon.social/@trwnh",
          "acct": "trwnh"
        }
      ],
      // ...
    }
  },
  {
    "id": "34975535",
    "type": "favourite",
    "created_at": "2019-11-23T07:29:18.903Z",
    "account": {
      "id": "297420",
      "username": "haskal",
      "acct": "haskal@cybre.space",
      // ...
    },
    "status": {
      "id": "103186046267791694",
      "created_at": "2019-11-23T07:28:34.210Z",
      "in_reply_to_id": "103186044372624124",
      "in_reply_to_account_id": "297420",
      // ...
      "account": {
        "id": "14715",
        "username": "trwnh",
        "acct": "trwnh",
        // ...
      }
    }
  }
]
*/

import 'package:fedi_pipe/models/mastodon_status.dart';

enum NotificationFeedType {
  all,
  mention,
  favourite,
  reblog,
  follow,
}

class MastodonNotificationModel {
  final String id;
  final String type;
  final String createdAt;
  final MastodonAccountModel account;
  final MastodonStatusModel? status;
  final String? groupKey; // Add this

  MastodonNotificationModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.account,
    this.status,
    this.groupKey, // Add this
  });

  factory MastodonNotificationModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    return MastodonNotificationModel(
      id: json['id'],
      type: json['type'],
      createdAt: json['created_at'],
      account: MastodonAccountModel.fromJson(json['account']),
      status: status != null ? MastodonStatusModel.fromJson(status) : null,
      groupKey: json['group_key'], // Add this
    );
  }

  static List<MastodonNotificationModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MastodonNotificationModel.fromJson(json)).toList();
  }
}

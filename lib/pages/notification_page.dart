import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/notification_feed.dart';
import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        body: NotificationFeed(
          feedType: NotificationFeedType.all,
        ),
        title: "Notifications");
  }
}

import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/notification_feed.dart';
import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationFeedType selected = NotificationFeedType.all;
  final List<NotificationFeedType> segments = [
    NotificationFeedType.all,
    NotificationFeedType.mention,
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<NotificationFeedType>(
                segments: segments
                    .map((segment) => ButtonSegment<NotificationFeedType>(label: Text(segment.name), value: segment))
                    .toList(),
                selected: {selected},
                onSelectionChanged: (selection) {
                  setState(() {
                    selected = selection.first;
                  });
                }),
            Expanded(
              child: NotificationFeed(
                key: ValueKey(selected),
                feedType: selected,
              ),
            ),
          ],
        ),
        title: "Notifications");
  }
}

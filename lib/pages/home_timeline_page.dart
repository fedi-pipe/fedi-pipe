import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/timeline_feed.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

class HomeTimelinePage extends StatefulWidget {
  const HomeTimelinePage({Key? key}) : super(key: key);

  @override
  State<HomeTimelinePage> createState() => _HomeTimelinePageState();
}

class _HomeTimelinePageState extends State<HomeTimelinePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(title: 'Home', body: TimelineFeed(feedType: FeedType.home));
  }
}

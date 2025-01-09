import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/components/timeline_feed.dart';
import 'package:fedi_pipe/pages/compose_page.dart';
import 'package:fedi_pipe/pages/drafts_page.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicTimelinePage extends StatefulWidget {
  const PublicTimelinePage({Key? key}) : super(key: key);

  @override
  State<PublicTimelinePage> createState() => _PublicTimelinePageState();
}

class _PublicTimelinePageState extends State<PublicTimelinePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "Public Timeline",
      body: TimelineFeed(
        feedType: FeedType.public,
      ),
    );
  }
}

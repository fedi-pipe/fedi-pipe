import 'package:fedi_pipe/components/mastodon_notification_card.dart';
import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/repositories/mastodon/notification_repository.dart';
import 'package:flutter/material.dart';

enum ScrollDirection { up, down }

class NotificationFeed extends StatefulWidget {
  NotificationFeedType feedType;
  NotificationFeed({Key? key, required this.feedType})
      : super(
          key: key,
        );

  @override
  _NotificationFeedState createState() => _NotificationFeedState();
}

class _NotificationFeedState extends State<NotificationFeed> {
  final ScrollController _scrollController = ScrollController();

  // The notifications currently in the timeline.
  List<MastodonNotificationModel> _notifications = [];

  // Indicates whether a fetch is in progress.
  bool _isLoading = false;

  // For link-based pagination; typically extracted from Mastodon Link headers,
  // but here we store them manually for demonstration.
  String? _nextId;
  String? _prevId;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(direction: ScrollDirection.up); // Initial load
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final pixels = position.pixels;
    final maxScroll = position.maxScrollExtent;

    // If scrolled near the bottom, fetch older notifications.
    if (pixels >= maxScroll - 200) {
      _fetchNotifications(direction: ScrollDirection.down);
    }

    // If scrolled near the top, fetch newer notifications.
    if (pixels <= 200) {
      _fetchNotifications(direction: ScrollDirection.up);
    }
  }

  void _fetchNotifications({required ScrollDirection direction}) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nextId = direction == ScrollDirection.up ? _notifications.firstOrNull?.id : null;
    final previousId = direction == ScrollDirection.down ? _notifications.lastOrNull?.id : null;

    final notifications = await MastodonNotificationRepository.fetchNotifications(
      previousId: previousId,
      nextId: nextId,
      feedType: widget.feedType,
    );

    setState(() {
      if (direction == ScrollDirection.up) {
        _notifications = [...notifications, ..._notifications];
      } else {
        _notifications = [..._notifications, ...notifications];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        cacheExtent: 5000,
        controller: _scrollController,
        itemCount: _notifications.length + 1,
        itemBuilder: (context, index) {
          if (index < _notifications.length) {
            return MastodonNotificationCard(
                key: ValueKey(_notifications[index].id), notification: _notifications[index]);
          } else {
            // Display a loader at the bottom if we're currently fetching
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }
}

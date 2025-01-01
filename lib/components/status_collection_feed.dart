import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

enum ScrollDirection { up, down }

class StatusCollectionFeed extends StatefulWidget {
  String collectionType;
  StatusCollectionFeed({Key? key, required this.collectionType})
      : super(
          key: key,
        );

  @override
  _StatusCollectionFeedState createState() => _StatusCollectionFeedState();
}

class _StatusCollectionFeedState extends State<StatusCollectionFeed> {
  final ScrollController _scrollController = ScrollController();

  // The statuses currently in the timeline.
  List<MastodonStatusModel> _statuses = [];

  // Indicates whether a fetch is in progress.
  bool _isLoading = false;

  // For link-based pagination; typically extracted from Mastodon Link headers,
  // but here we store them manually for demonstration.
  String? _nextId;
  String? _prevId;

  @override
  void initState() {
    super.initState();
    _fetchStatuses(direction: ScrollDirection.up); // Initial load
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    return;
    final position = _scrollController.position;
    final pixels = position.pixels;
    final maxScroll = position.maxScrollExtent;

    // If scrolled near the bottom, fetch older statuses.
    if (pixels >= maxScroll - 200) {
      _fetchStatuses(direction: ScrollDirection.down);
    }

    // If scrolled near the top, fetch newer statuses.
    if (pixels <= 200) {
      _fetchStatuses(direction: ScrollDirection.up);
    }
  }

  void _fetchStatuses({required ScrollDirection direction}) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nextId = direction == ScrollDirection.up ? _statuses.firstOrNull?.id : null;
    final previousId = direction == ScrollDirection.down ? _statuses.lastOrNull?.id : null;

    final statuses = await MastodonStatusRepository.fetchCollection(
      widget.collectionType,
    );

    setState(() {
      if (direction == ScrollDirection.up) {
        _statuses = [...statuses, ..._statuses];
      } else {
        _statuses = [..._statuses, ...statuses];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _statuses.length + 1,
      itemBuilder: (context, index) {
        if (index < _statuses.length) {
          return MastodonStatusCard(key: ValueKey(_statuses[index].id), status: _statuses[index]);
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
    );
  }
}

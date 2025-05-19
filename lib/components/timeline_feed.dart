import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

enum ScrollDirection { up, down }

class TimelineFeed extends StatefulWidget {
  FeedType feedType;
  TimelineFeed({Key? key, required this.feedType})
      : super(
          key: key,
        );

  @override
  _TimelineFeedState createState() => _TimelineFeedState();
}

class _TimelineFeedState extends State<TimelineFeed> {
  final ScrollController _scrollController = ScrollController();

  // The statuses currently in the timeline.
  List<MastodonStatusModel> _statuses = [];

  // Indicates whether a fetch is in progress.
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _fetchStatuses(direction: ScrollDirection.refresh); // Initial load is a refresh
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

    // If scrolled near the bottom, fetch older statuses.
    if (pixels >= maxScroll - 200 && !_isLoading) { // check !_isLoading
      _fetchStatuses(direction: ScrollDirection.down);
    }

    // Upward scroll to fetch newer items is less common with pull-to-refresh,
    // but can be kept if desired.
    // if (pixels <= 200 && !_isLoading) { // check !_isLoading
    //   _fetchStatuses(direction: ScrollDirection.up);
    // }
  }

  Future<void> _fetchStatuses({required ScrollDirection direction}) async { // Return Future<void>
    if (_isLoading) {
      return;
    }

    if (mounted) { // Check mounted before initial setState
        setState(() {
        _isLoading = true;
        });
    }


    String? fetchNextId;    // Renamed from nextId to avoid conflict
    String? fetchPreviousId; // Renamed from previousId

    if (direction == ScrollDirection.refresh) {
      // For refresh, we want the newest items.
      // Simplest approach: clear and fetch fresh.
      // Or, if fetching newer than the current newest:
      // fetchNextId = _statuses.isNotEmpty ? _statuses.first.id : null;
      _statuses.clear(); // Clear list for a full refresh
    } else if (direction == ScrollDirection.up && _statuses.isNotEmpty) {
      fetchNextId = _statuses.first.id;
    } else if (direction == ScrollDirection.down && _statuses.isNotEmpty) {
      fetchPreviousId = _statuses.last.id;
    }

    try {
      final newStatuses = await MastodonStatusRepository.fetchStatuses(
        previousId: fetchPreviousId,
        nextId: fetchNextId,
        feedType: widget.feedType,
      );

      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          if (direction == ScrollDirection.refresh || direction == ScrollDirection.up) {
            // For refresh or fetching newer, prepend new statuses.
            // Ensure no duplicates if API might return overlapping items.
            // A more robust way might be to use a Set of IDs for existing statuses.
            final existingIds = _statuses.map((s) => s.id).toSet();
            _statuses = [...newStatuses.where((ns) => !existingIds.contains(ns.id)), ..._statuses];
          } else { // ScrollDirection.down
            // Append older statuses.
            final existingIds = _statuses.map((s) => s.id).toSet();
            _statuses = [..._statuses, ...newStatuses.where((ns) => !existingIds.contains(ns.id))];
          }
        });
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching statuses: ${e.toString()}'))
        );
        print('Error fetching statuses: $e'); // Also log to console
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 5000,
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

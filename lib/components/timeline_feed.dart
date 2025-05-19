import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

enum ScrollDirection { up, down, refresh }

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

    if (pixels >= maxScroll - 200 && !_isLoading) { // check !_isLoading for pagination
      _fetchStatuses(direction: ScrollDirection.down);
    }

    // Upward scroll for fetching newer items via scroll is generally replaced by pull-to-refresh.
    // if (pixels <= 200 && !_isLoading) {
    //   _fetchStatuses(direction: ScrollDirection.up);
    // }
  }

  Future<void> _fetchStatuses({required ScrollDirection direction}) async {
    // Allow refresh action even if another load (e.g. pagination) was ongoing.
    // For pagination (up/down), prevent concurrent calls if already loading.
    if (_isLoading && direction != ScrollDirection.refresh) {
      return;
    }

    // If a refresh is triggered, it takes precedence.
    // No need to explicitly cancel other futures here unless complex state management is needed.
    // The RefreshIndicator expects this onRefresh Future to complete.

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String? fetchNextId;
    String? fetchPreviousId;

    if (direction == ScrollDirection.refresh) {
      // For refresh, always clear existing statuses to fetch the newest.
      _statuses.clear();
      // nextId and previousId remain null to fetch the latest timeline.
    } else if (direction == ScrollDirection.up && _statuses.isNotEmpty) {
      fetchNextId = _statuses.first.id;
    } else if (direction == ScrollDirection.down && _statuses.isNotEmpty) {
      fetchPreviousId = _statuses.last.id;
    }

    try {
      // Simulate network delay for refresh indicator visibility if API is too fast
      // if (direction == ScrollDirection.refresh) {
      //   await Future.delayed(Duration(milliseconds: 700));
      // }

      final newStatuses = await MastodonStatusRepository.fetchStatuses(
        previousId: fetchPreviousId,
        nextId: fetchNextId,
        feedType: widget.feedType,
      );

      if (mounted) {
        setState(() {
          final existingIds = _statuses.map((s) => s.id).toSet();
          List<MastodonStatusModel> uniqueNewStatuses = newStatuses.where((ns) => !existingIds.contains(ns.id)).toList();

          if (direction == ScrollDirection.refresh || direction == ScrollDirection.up) {
            _statuses.insertAll(0, uniqueNewStatuses);
          } else { // ScrollDirection.down
            _statuses.addAll(uniqueNewStatuses);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching statuses: ${e.toString()}'))
        );
        print('Error fetching statuses: $e');
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

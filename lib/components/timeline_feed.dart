import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

// Added 'refresh' to distinguish the pull-to-refresh action
enum ScrollDirection { up, down, refresh }

class TimelineFeed extends StatefulWidget {
  final FeedType feedType; // Assuming FeedType is defined in status_repository.dart
  const TimelineFeed({Key? key, required this.feedType}) : super(key: key);

  @override
  _TimelineFeedState createState() => _TimelineFeedState();
}

class _TimelineFeedState extends State<TimelineFeed> {
  final ScrollController _scrollController = ScrollController();
  List<MastodonStatusModel> _statuses = [];
  bool _isLoading = false;
  // _nextId and _prevId for pagination are determined dynamically in _fetchStatuses

  @override
  void initState() {
    super.initState();
    // Initial load is treated as a refresh
    _fetchStatuses(direction: ScrollDirection.refresh);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Clean up listener
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Fetch older statuses when scrolled near the bottom
      _fetchStatuses(direction: ScrollDirection.down);
    }
    // Fetching newer statuses via upward scroll is less common with pull-to-refresh
    // but can be added here if needed, similar to the downward scroll logic.
  }

  Future<void> _fetchStatuses({required ScrollDirection direction}) async {
    // Allow refresh action to proceed even if another type of load was ongoing.
    // For pagination (up/down), prevent concurrent calls if already loading.
    if (_isLoading && direction != ScrollDirection.refresh) {
      return;
    }

    if (mounted) {
      setState(() {
        // For a refresh action initiated by RefreshIndicator, it shows its own spinner.
        // For pagination, _isLoading helps show a loader at the list bottom.
        _isLoading = true;
      });
    }

    String? fetchNextId; // To fetch statuses newer than this ID
    String? fetchPreviousId; // To fetch statuses older than this ID

    if (direction == ScrollDirection.refresh) {
      // For refresh, clear existing statuses and fetch the newest.
      // No specific ID needed initially, or API might take 'since_id'.
      // For simplicity, we clear and fetch.
    } else if (direction == ScrollDirection.up && _statuses.isNotEmpty) {
      fetchNextId = _statuses.first.id;
    } else if (direction == ScrollDirection.down && _statuses.isNotEmpty) {
      fetchPreviousId = _statuses.last.id;
    }

    try {
      // Simulate network delay to see the indicator if API is too fast
      // if (direction == ScrollDirection.refresh) {
      //   await Future.delayed(const Duration(milliseconds: 700));
      // }

      final newStatuses = await MastodonStatusRepository.fetchStatuses(
        previousId: fetchPreviousId,
        nextId: fetchNextId,
        feedType: widget.feedType,
      );

      if (mounted) {
        setState(() {
          if (direction == ScrollDirection.refresh) {
            _statuses = newStatuses; // Replace list on refresh
          } else if (direction == ScrollDirection.up) {
            // Prepend new statuses, avoiding duplicates
            final existingIds = _statuses.map((s) => s.id).toSet();
            _statuses.insertAll(0, newStatuses.where((ns) => !existingIds.contains(ns.id)));
          } else {
            // ScrollDirection.down
            // Append older statuses, avoiding duplicates
            final existingIds = _statuses.map((s) => s.id).toSet();
            _statuses.addAll(newStatuses.where((ns) => !existingIds.contains(ns.id)));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching statuses: ${e.toString()}')));
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
    return RefreshIndicator(
      onRefresh: () => _fetchStatuses(direction: ScrollDirection.refresh),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // Case 1: Initial load (statuses empty, isLoading true)
    // RefreshIndicator shows its own spinner. We can show a minimal list view.
    if (_statuses.isEmpty && _isLoading) {
      // The RefreshIndicator is already showing a spinner.
      // Return a ListView with minimum content so it's scrollable,
      // or a SizedBox if RefreshIndicator handles empty child well.
      // For safety, let's ensure it's scrollable.
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Take full height
          child: const Center(child: SizedBox.shrink()), // RefreshIndicator is showing
        ),
      );
    }

    // Case 2: No statuses after load (statuses empty, isLoading false)
    if (_statuses.isEmpty && !_isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Essential for RefreshIndicator
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    widget.feedType == FeedType.home
                        ? "Nothing to see here yet!\nTry following some accounts or pull to refresh."
                        : "No statuses to display.\nPull to refresh.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Case 3: Statuses available
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Essential for RefreshIndicator
      cacheExtent: 5000, // Keep this if it helps performance
      controller: _scrollController,
      // Add 1 for the loader if loading more items (not on initial refresh)
      itemCount: _statuses.length + (_isLoading && directionCurrentlyFetching != ScrollDirection.refresh ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _statuses.length) {
          return MastodonStatusCard(key: ValueKey(_statuses[index].id), status: _statuses[index]);
        } else if (_isLoading && directionCurrentlyFetching != ScrollDirection.refresh) {
          // Show loader at the bottom for pagination
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox.shrink(); // Should not be reached
      },
    );
  }

  // Helper to know what type of fetch is happening, for conditional loader
  ScrollDirection? get directionCurrentlyFetching {
    // This is a simplified way; a more robust solution might involve storing
    // the current fetching direction in the state if multiple types of fetches
    // could overlap in complex ways. For now, if _isLoading is true,
    // we assume it's for pagination if not initial refresh.
    if (_isLoading) {
      // Heuristic: if list is empty, it's likely a refresh. If not, pagination.
      // This is not perfect. A dedicated state variable for 'currentFetchType' would be better.
      return _statuses.isEmpty ? ScrollDirection.refresh : ScrollDirection.down; // Default to down for pagination
    }
    return null;
  }
}


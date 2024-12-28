import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/main.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
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

enum ScrollDirection { up, down }

class _PublicTimelinePageState extends State<PublicTimelinePage> {
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

  /// Fetches statuses in the specified direction, using `_nextId` or `_prevId`.
  ///
  /// Note: Make sure your [MastodonStatusRepository] methods actually handle
  /// `nextId` or `previousId` properly (often this comes from Mastodon’s Link headers).
  Future<void> _fetchStatuses({
    ScrollDirection direction = ScrollDirection.down,
  }) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (direction == ScrollDirection.up) {
        // Load newer statuses (future)
        final newStatuses = await MastodonStatusRepository.fetchStatuses(nextId: _nextId);

        if (newStatuses.isNotEmpty) {
          setState(() {
            _statuses.insertAll(0, newStatuses);
            // In a real app, you would parse the Link headers (or the returned JSON)
            // to find the actual next/prev IDs. For demonstration:

            _prevId ??= _statuses.last.id; // set if it's null
            _nextId = _statuses.first.id;
          });
        } else {}
      } else {
        // Load older statuses (past)
        final oldStatuses = await MastodonStatusRepository.fetchStatuses(previousId: _prevId);

        if (oldStatuses.isNotEmpty) {
          setState(() {
            // Insert new statuses at the top
            _statuses.addAll(oldStatuses);
            // Update IDs
            _prevId = _statuses.last.id;
            _nextId ??= _statuses.first.id; // set if it's null
          });
        } else {}
      }
    } catch (e, st) {
      debugPrint('Error fetching statuses: $e\n$st');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Timeline'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ComposePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: const Text('Fedi Pipe'),
              decoration: BoxDecoration(),
            ),
            ListTile(
              title: const Text('Public Timeline'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Local Timeline'),
              onTap: () {
                Navigator.of(context).pushNamed('/local');
              },
            ),
            ListTile(
              title: const Text('Federated Timeline'),
              onTap: () {
                Navigator.of(context).pushNamed('/federated');
              },
            ),
            ListTile(
              title: const Text('Manage Accounts'),
              onTap: () {
                context.pushNamed('manage-accounts');
              },
            ),
            ListTile(
              title: const Text('drafts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DraftsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _statuses.length + 1, // +1 for the bottom progress indicator
        itemBuilder: (context, index) {
          // If it's not the final "loading" widget, build a status card
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
      ),
    );
  }
}

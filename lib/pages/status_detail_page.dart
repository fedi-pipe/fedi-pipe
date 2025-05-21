import 'package:flutter/material.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/models/status_context_model.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:fedi_pipe/components/mastodon_status_card.dart';
// Consider adding a skeleton loader import later
// import 'package:fedi_pipe/components/skeletons/status_skeleton.dart'; // If you create one

class StatusDetailPage extends StatefulWidget {
  final String statusId;
  final MastodonStatusModel? initialStatus;

  const StatusDetailPage({
    super.key,
    required this.statusId,
    this.initialStatus,
  });

  @override
  State<StatusDetailPage> createState() => _StatusDetailPageState();
}

class _StatusDetailPageState extends State<StatusDetailPage> {
  MastodonStatusModel? _mainStatus;
  StatusContextModel? _statusContext;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mainStatus = widget.initialStatus;
    if (_mainStatus == null) {
      _isLoading = true; 
    } else {
      // If initial status is provided, we might not need to show a full page loader initially,
      // but we still need to fetch the context.
      _isLoading = false; // Or true if you prefer to load everything together
    }
    _fetchStatusDetails();
  }

  Future<void> _fetchStatusDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Set loading true at the beginning of any fetch operation
      _error = null;
    });

    try {
      // Fetch main status, even if initialStatus was provided, to get latest data.
      // Or, only fetch if _mainStatus is null: final statusFuture = _mainStatus == null ? MastodonStatusRepository.fetchStatus(widget.statusId) : Future.value(_mainStatus);
      final statusFuture = MastodonStatusRepository.fetchStatus(widget.statusId);
      final contextFuture = MastodonStatusRepository.fetchContext(widget.statusId);

      // Wait for both futures to complete
      final results = await Future.wait([statusFuture, contextFuture]);
      
      if (!mounted) return; // Check if the widget is still in the tree
      
      setState(() {
        _mainStatus = results[0] as MastodonStatusModel;
        _statusContext = results[1] as StatusContextModel;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Check again
      setState(() {
        _error = "Failed to load status details: ${e.toString()}";
        print("Error in _fetchStatusDetails: $_error"); // For debugging
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mainStatus?.account.displayName ?? _mainStatus?.account.username ?? 'Status Detail'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _mainStatus == null) { // Primary loading state
      // TODO: Consider a more descriptive skeleton loader here.
      // For now, using CircularProgressIndicator.
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchStatusDetails,
                child: Text('Retry'),
              )
            ],
          ),
        ),
      );
    }
    
    if (_mainStatus == null) {
      // This state might be reached if loading finished without error but status is still null.
      return Center(child: Text('Status not found.'));
    }

    // At this point, _mainStatus is available. _statusContext might still be loading if initialStatus was provided
    // or if the context fetch part of _fetchStatusDetails is ongoing / failed separately.

    List<Widget> slivers = [];

    // Ancestors
    if (_statusContext?.ancestors != null && _statusContext!.ancestors.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("In reply to:", style: Theme.of(context).textTheme.titleSmall),
        ),
      ));
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: MastodonStatusCard(status: _statusContext!.ancestors[index]),
            );
          },
          childCount: _statusContext!.ancestors.length,
        ),
      ));
       slivers.add(SliverToBoxAdapter(child: Divider(indent: 16, endIndent: 16)));
    }

    // Main Status
    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: MastodonStatusCard(status: _mainStatus!),
      ),
    ));

    // Descendants (Replies)
    if (_statusContext != null) { // Context has been loaded or attempted
        if (_statusContext!.descendants.isNotEmpty) {
            slivers.add(SliverToBoxAdapter(child: Divider(indent: 16, endIndent: 16)));
            slivers.add(SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text("Replies:", style: Theme.of(context).textTheme.titleSmall),
            ),
            ));
            slivers.add(SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: MastodonStatusCard(status: _statusContext!.descendants[index]),
                );
                },
                childCount: _statusContext!.descendants.length,
            ),
            ));
        } else { // No descendants
             slivers.add(SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text("No replies yet.")),
              ),
            ));
        }
    } else if (_isLoading) { // Context is still loading separately
        slivers.add(SliverToBoxAdapter(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
            ),
        ));
    }
    
    return RefreshIndicator(
      onRefresh: _fetchStatusDetails,
      child: CustomScrollView(
        slivers: slivers,
      ),
    );
  }
}

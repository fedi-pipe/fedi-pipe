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
    // Implementation in a later step
    if (_isLoading && _mainStatus == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_mainStatus == null) {
      return Center(child: Text('Status not found.'));
    }
    return Center(child: Text('Content for status ID: ${widget.statusId} will be displayed here. Full UI in next steps.'));
  }
}

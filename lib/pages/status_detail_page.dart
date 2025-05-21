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
    // Implementation in next step
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

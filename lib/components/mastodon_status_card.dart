import 'package:fedi_pipe/gale_showcase.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:flutter/material.dart';

class MastodonStatusCard extends StatefulWidget {
  const MastodonStatusCard({super.key, required this.status});

  final MastodonStatus status;

  @override
  State<MastodonStatusCard> createState() => _MastodonStatusCardState();
}

class _MastodonStatusCardState extends State<MastodonStatusCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              foregroundImage: NetworkImage(widget.status.accountAvatarUrl),
            ),
            title: Text(widget.status.accountDisplayName),
            subtitle: Text(widget.status.createdAt),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.status.content),
          ),
        ],
      ),
    );
  }
}

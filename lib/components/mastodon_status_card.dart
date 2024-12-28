import 'package:fedi_pipe/components/dom_node_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';

class MastodonStatusCard extends StatefulWidget {
  const MastodonStatusCard({super.key, required this.status});

  final MastodonStatusModel status;

  @override
  State<MastodonStatusCard> createState() => _MastodonStatusCardState();
}

class _MastodonStatusCardState extends State<MastodonStatusCard> {
  late Future<DOMNode> domNode;

  @override
  void initState() {
    super.initState();
    domNode = HTMLParser(widget.status.content).parse();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: FutureBuilder(
                future: domNode,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CircularProgressIndicator();
                  }
                  return Text.rich(
                    DomNodeRenderer(node: snapshot.data!).render(),
                    softWrap: true,
                  );
                }),
          ),
        ],
      ),
    );
  }
}

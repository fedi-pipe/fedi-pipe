import 'package:fedi_pipe/components/dom_node_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
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
    final status = widget.status.reblog ?? widget.status;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              foregroundImage: NetworkImage(status.accountAvatarUrl),
            ),
            title: Text("${status.accountDisplayName} (@${status.acct})"),
            subtitle: GestureDetector(
                onTap: () {
                  MastodonStatusRepository.fetchStatus(widget.status.id);
                },
                child: Text(status.createdAt)),
          ),
          if (status.reblog != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Boosted by @${widget.status.acct}",
                textAlign: TextAlign.right,
              ),
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
          // 4 column grid for media attachments
          if (status.mediaAttachments.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: status.mediaAttachments.length,
              itemBuilder: (context, index) {
                final media = status.mediaAttachments[index];
                return Image.network(media.previewUrl!);
              },
            ),
          if (widget.status.card != null) _renderCard(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
              icon: Row(
                children: [
                  Icon(Icons.comment),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Text(status.repliesCount.toString()),
                ],
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Row(
                children: [
                  Icon(Icons.repeat),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Text(status.reblogsCount.toString()),
                ],
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Row(
                children: [
                  Icon(Icons.favorite),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Text(status.favouritesCount.toString()),
                ],
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {},
            ),
          ])
        ],
      ),
    );
  }

  Padding _renderCard() {
    final card = widget.status.card!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                foregroundImage: card.image != null ? NetworkImage(card.image!) : null,
              ),
              title: Text(card.title!),
              subtitle: Text(card.description!),
            ),
            if (card.url != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(status.card!.url!),
              ),
          ],
        ),
      ),
    );
  }
}

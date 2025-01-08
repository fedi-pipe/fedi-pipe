import 'dart:convert';

import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/extensions/string.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:popover/popover.dart';
import 'package:url_launcher/url_launcher.dart';

class MastodonStatusCard extends StatefulWidget {
  const MastodonStatusCard({super.key, required this.status});

  final MastodonStatusModel status;

  @override
  State<MastodonStatusCard> createState() => _MastodonStatusCardState();
}

class _MastodonStatusCardState extends State<MastodonStatusCard> {
  late final bookmarkConfettiController = ConfettiController();
  late final favouriteConfettiController = ConfettiController();
  late final MastodonStatusModel status;

  late bool isBookmarked;
  late bool isFavourited;
  late bool isReblogged;

  late int favouriteCount;
  late int reblogCount;

  @override
  void initState() {
    super.initState();
    status = widget.status.reblog ?? widget.status;

    isBookmarked = status.bookmarked;
    isFavourited = status.favourited;
    isReblogged = status.reblogged;

    favouriteCount = status.favouritesCount;
    reblogCount = status.reblogsCount;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MastodonStatusCardBody(status: status, originalStatus: widget.status),
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
                return GestureDetector(
                    onTap: () {
                      final previewUrl = media.previewUrl!;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: InteractiveViewer(clipBehavior: Clip.none, child: Image.network(previewUrl)),
                          );
                        },
                      );
                    },
                    child: Image.network(media.previewUrl!));
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
              onPressed: () {
                showDialog(context: context, builder: (ctx) => ReplyDialogBody(status: status));
              },
            ),
            IconButton(
              color: isReblogged ? primaryColor : null,
              icon: Row(
                children: [
                  Icon(Icons.repeat),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Text(status.reblogsCount.toString(),
                      style: TextStyle(
                          color: isReblogged ? primaryColor : null, fontWeight: isReblogged ? FontWeight.bold : null)),
                ],
              ),
              onPressed: () {
                setState(() {
                  isReblogged = !isReblogged;
                });
              },
            ),
            Stack(
              children: [
                Positioned(
                  left: 20,
                  bottom: 10,
                  child: Container(
                      width: 0,
                      height: 0,
                      child: Confetti(
                          particleBuilder: (index) => Emoji(
                                emoji: "❤️",
                              ),
                          controller: favouriteConfettiController,
                          options: ConfettiOptions(
                            particleCount: 20,
                            startVelocity: 20,
                            spread: 30,
                            gravity: 0.7,
                            y: 0,
                          ))),
                ),
                IconButton(
                  color: isFavourited ? primaryColor : null,
                  icon: Row(
                    children: [
                      Icon(Icons.favorite),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Text(favouriteCount.toString(),
                          style: TextStyle(
                              color: isFavourited ? primaryColor : null,
                              fontWeight: isFavourited ? FontWeight.bold : null)),
                    ],
                  ),
                  onPressed: () {
                    if (isFavourited) {
                      setState(() {
                        isFavourited = false;
                        favouriteCount--;
                      });
                      MastodonStatusRepository.unfavouriteStatus(status.id);
                    } else {
                      setState(() {
                        isFavourited = true;
                        favouriteCount++;
                      });
                      MastodonStatusRepository.favouriteStatus(status.id);
                      favouriteConfettiController.launch();
                    }
                  },
                ),
              ],
            ),
            Stack(
              children: [
                Positioned(
                  left: 20,
                  bottom: 10,
                  child: Container(
                      width: 0,
                      height: 0,
                      child: Confetti(
                          particleBuilder: (index) => Emoji(
                                emoji: "🔖",
                              ),
                          controller: bookmarkConfettiController,
                          options: ConfettiOptions(
                            particleCount: 20,
                            startVelocity: 20,
                            spread: 30,
                            gravity: 0.7,
                            y: 0,
                          ))),
                ),
                IconButton(
                  color: isBookmarked ? primaryColor : null,
                  icon: Icon(isBookmarked ? Icons.bookmark_added : Icons.bookmark_add
                      //Icons.bookmark,
                      ),
                  onPressed: () {
                    if (isBookmarked) {
                      setState(() {
                        isBookmarked = false;
                      });
                      MastodonStatusRepository.unbookmarkStatus(status.id);
                    } else {
                      setState(() {
                        isBookmarked = true;
                      });
                      MastodonStatusRepository.bookmarkStatus(status.id);
                      bookmarkConfettiController.launch();
                    }
                  },
                ),
              ],
            ),
          ])
        ],
      ),
    );
  }

  Widget _renderCard() {
    final card = widget.status.card!;
    return GestureDetector(
      onTap: () {
        final uri = Uri.parse(card.url!);
        launchUrl(uri);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      foregroundImage: card.image != null ? NetworkImage(card.image!) : null,
                    ),
                  ],
                ),
                title: Text(
                  card.title!,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(card.description!.clamp(140)),
              ),
              if (card.url != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(status.card!.url!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MastodonStatusCardBody extends StatelessWidget {
  const MastodonStatusCardBody({
    super.key,
    required this.status,
    required this.originalStatus,
  });

  final MastodonStatusModel status;
  final MastodonStatusModel originalStatus;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        leading: MastodonAccountAvatar(status: status),
        title: Text("${status.accountDisplayName} (@${status.acct})"),
        subtitle: GestureDetector(
            onDoubleTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => Container(
                      height: 200,
                      color: Colors.white,
                      child: ListView(
                        children: [
                          Text(jsonEncode(status.json)),
                        ],
                      )));
            },
            onTap: () {
              MastodonStatusRepository.fetchStatus(originalStatus.id);
            },
            child: Text(status.createdAt)),
      ),
      if (originalStatus.reblog != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Boosted by @${originalStatus.acct}",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlRenderer(html: status.content),
      )
    ]);
  }
}

class MastodonAccountAvatar extends StatelessWidget {
  const MastodonAccountAvatar({
    super.key,
    required this.status,
  });

  final MastodonStatusModel status;

  @override
  Widget build(BuildContext context) {
    final account = status.account;
    return GestureDetector(
      onLongPress: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => MastodonAccountPreview(account: account),
          onPop: () {},
          direction: PopoverDirection.top,
          width: 250,
          arrowWidth: 20,
          arrowDyOffset: 10,
          constraints: BoxConstraints(
            maxHeight: 400,
          ),
        );
      },
      child: CircleAvatar(
        foregroundImage: NetworkImage(status.accountAvatarUrl),
      ),
    );
  }
}

class MastodonAccountPreview extends StatefulWidget {
  const MastodonAccountPreview({
    super.key,
    required this.account,
  });

  final MastodonAccountModel account;

  @override
  State<MastodonAccountPreview> createState() => _MastodonAccountPreviewState();
}

class _MastodonAccountPreviewState extends State<MastodonAccountPreview> {
  late Future<DOMNode> domNode;

  @override
  void initState() {
    super.initState();
    domNode = HTMLParser(widget.account.note ?? "").parse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                foregroundImage: NetworkImage(widget.account.avatar!),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text("@${widget.account.acct!}"),
          Text(widget.account.username),
          SizedBox(height: 8),
          HtmlRenderer(html: widget.account.note!),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              final data = [widget.account.followersCount, widget.account.followingCount, widget.account.statusesCount];
              final labels = ["Followers", "Following", "Statuses"];
              return Column(
                children: [
                  Text(data[index].toString()),
                  Text(labels[index]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReplyDialogBody extends StatefulWidget {
  final MastodonStatusModel status;
  const ReplyDialogBody({super.key, required this.status});

  @override
  State<ReplyDialogBody> createState() => _ReplyDialogBodyState();
}

class _ReplyDialogBodyState extends State<ReplyDialogBody> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  late final MastodonStatusModel status;
  late Future<DOMNode> domNode;

  @override
  void initState() {
    super.initState();
    status = widget.status.reblog ?? widget.status;
    domNode = HTMLParser(status.content).parse();

    final text = "${status.replyMentions().join(' ')} ";
    _controller = TextEditingController(text: text);

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
      },
      child: SingleChildScrollView(
        child: Container(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.translucent,
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
                  child: Card(
                      shadowColor: Colors.transparent,
                      child: MastodonStatusCardBody(status: status, originalStatus: widget.status))),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[300]),
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Card(
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      borderOnForeground: false,
                      surfaceTintColor: Colors.transparent,
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        decoration: InputDecoration(hintText: "Reply"),
                        maxLines: 3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      ElevatedButton(
                          onPressed: () {
                            MastodonStatusRepository.replyToStatus(status.id, _controller.text);
                            Navigator.of(context).pop();
                          },
                          child: Text("Reply")),
                    ])
                  ],
                ),
              )
            ]),
          ),
        )),
      ),
    );
  }
}

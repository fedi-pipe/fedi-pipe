import 'dart:convert';

import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:go_router/go_router.dart';
import 'package:fedi_pipe/components/mastodon_profile_bottom_sheet.dart';
import 'package:fedi_pipe/components/shared_component_widget.dart';
import 'package:fedi_pipe/extensions/string.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:fluttertagger/fluttertagger.dart';
import 'package:popover/popover.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

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
          if (status.mediaAttachments.isNotEmpty) AttachmentRenderer(status: status),
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
              if (card.image != null)
                Image.network(
                  card.image!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ListTile(
                leading: (card.image == null)
                    ? Container(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.link),
                      )
                    : null,
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

class AttachmentRenderer extends StatefulWidget {
  const AttachmentRenderer({
    super.key,
    required this.status,
  });

  final MastodonStatusModel status;

  @override
  State<AttachmentRenderer> createState() => _AttachmentRendererState();
}

class _AttachmentRendererState extends State<AttachmentRenderer> {
  Widget renderSingleAttachment(List<MediaAttachmentModel> mediaAttachments) {
    final attachment = mediaAttachments[0];
    return GestureDetector(
      onTap: () {
        final previewUrl = attachment.previewUrl!;
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: InteractiveViewer(clipBehavior: Clip.none, child: Image.network(previewUrl)),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(width: double.infinity, height: 200, fit: BoxFit.cover, attachment.previewUrl!),
        ),
      ),
    );
  }

  Widget renderDoubleAttachment(List<MediaAttachmentModel> mediaAttachments) {
    final firstAttachment = mediaAttachments[0];
    final secondAttachment = mediaAttachments[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final previewUrl = firstAttachment.previewUrl!;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: InteractiveViewer(clipBehavior: Clip.none, child: Image.network(previewUrl)),
                      );
                    },
                  );
                },
                child:
                    Image.network(width: double.infinity, height: 200, fit: BoxFit.cover, firstAttachment.previewUrl!),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final previewUrl = secondAttachment.previewUrl!;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: InteractiveViewer(clipBehavior: Clip.none, child: Image.network(previewUrl)),
                      );
                    },
                  );
                },
                child:
                    Image.network(width: double.infinity, height: 200, fit: BoxFit.cover, secondAttachment.previewUrl!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderTripleAttachment(
    List<MediaAttachmentModel> mediaAttachments,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // LEFT SIDE (one tall image)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final url = mediaAttachments[0].previewUrl!;
                  _showImageDialog(context, url);
                },
                child: Image.network(
                  mediaAttachments[0].previewUrl!,
                  fit: BoxFit.cover,
                  height: 300, // ensures it matches the container height
                ),
              ),
            ),
            const SizedBox(width: 4),
            // RIGHT SIDE (two stacked images each 146 in height)
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final url = mediaAttachments[1].previewUrl!;
                      _showImageDialog(context, url);
                    },
                    child: SizedBox(
                      child: Image.network(
                        mediaAttachments[1].previewUrl!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final url = mediaAttachments[2].previewUrl!;
                      _showImageDialog(context, url);
                    },
                    child: SizedBox(
                      child: Image.network(
                        mediaAttachments[2].previewUrl!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget renderQuadMediaAttachment(List<MediaAttachmentModel> mediaAttachments) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageDialog(context, mediaAttachments[0].previewUrl!),
                      child: Image.network(
                        height: double.infinity,
                        width: double.infinity,
                        mediaAttachments[0].previewUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageDialog(context, mediaAttachments[1].previewUrl!),
                      child: Image.network(
                        height: double.infinity,
                        width: double.infinity,
                        mediaAttachments[1].previewUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageDialog(context, mediaAttachments[2].previewUrl!),
                      child: Image.network(
                        height: double.infinity,
                        width: double.infinity,
                        mediaAttachments[2].previewUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageDialog(context, mediaAttachments[3].previewUrl!),
                      child: Image.network(
                        height: double.infinity,
                        width: double.infinity,
                        mediaAttachments[3].previewUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          child: Image.network(url),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status.mediaAttachments.length == 1) {
      return renderSingleAttachment(widget.status.mediaAttachments);
    }
    if (widget.status.mediaAttachments.length == 2) {
      return renderDoubleAttachment(widget.status.mediaAttachments);
    }

    if (widget.status.mediaAttachments.length == 3) {
      return renderTripleAttachment(widget.status.mediaAttachments);
    }

    if (widget.status.mediaAttachments.length == 4) {
      return renderQuadMediaAttachment(widget.status.mediaAttachments);
    }
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: widget.status.mediaAttachments.length,
      itemBuilder: (context, index) {
        final media = widget.status.mediaAttachments[index];
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
      if (originalStatus.reblog != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Boosted by @${originalStatus.acct}",
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            MastodonAccountAvatar(status: status),
            if (originalStatus.reblog != null)
              Positioned(
                right: -8,
                bottom: -8,
                child: CircleAvatar(
                  radius: 16,
                  foregroundImage: NetworkImage(originalStatus.accountAvatarUrl),
                ),
              ),
          ],
        ),
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
              // Navigate to the StatusDetailPage
              context.pushNamed(
                'statusDetail',
                pathParameters: {'id': status.id},
                extra: originalStatus, // Pass the full status object
              );
            },
            child: Text(timeago.format(DateTime.parse(status.createdAt)))),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: HtmlRenderer(
          html: status.content,
          onMentionTapped: (acctIdentifier) {
            showMastodonProfileBottomSheetWithLoading(context, acctIdentifier);
          },
        ),
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
      onTap: () {
        showMastodonProfileBottomSheet(context, account);
      },
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(status.accountAvatarUrl),
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
          SizedBox(height: 4),
          Text("@${widget.account.acct!}"),
          Text(widget.account.username),
          SizedBox(height: 4),
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
  late final FlutterTaggerController _replyTaggerController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final MastodonStatusModel _effectiveStatus;

  @override
  void initState() {
    super.initState();
    _effectiveStatus = widget.status.reblog ?? widget.status;
    final initialReplyText = "${_effectiveStatus.replyMentions().join(' ')} ";
    _replyTaggerController = FlutterTaggerController(text: initialReplyText);

    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _replyTaggerController.selection = TextSelection.fromPosition(
          TextPosition(offset: _replyTaggerController.text.length),
        );
        // Attempt an initial scroll after a short delay,
        // in case the keyboard is already up or for immediate visibility.
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && _focusNode.hasFocus) {
            _scrollToShowFocusedInput();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _replyTaggerController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && mounted) {
      // Delay to allow keyboard animation and layout reflow
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && _focusNode.hasFocus) {
          _scrollToShowFocusedInput();
        }
      });
    }
  }

  void _scrollToShowFocusedInput() {
    if (!mounted || !_focusNode.hasPrimaryFocus) return;

    final BuildContext? focusedContext = _focusNode.context;
    if (focusedContext != null) {
      final RenderObject? renderObject = focusedContext.findRenderObject();
      if (renderObject != null) {
        final ScrollableState? scrollableState = Scrollable.maybeOf(focusedContext);
        if (scrollableState != null && scrollableState.position.hasPixels) {
          scrollableState.position.ensureVisible(
            renderObject,
            alignment: 0.1, // Try to show a bit of context above (0.0 is top, 0.5 is center)
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topSystemPadding = mediaQuery.padding.top; // Height of the status bar
    final keyboardHeight = mediaQuery.viewInsets.bottom; // Height of the keyboard when visible

    // Desired vertical margin for the dialog from the safe areas of the screen
    const double verticalDialogScreenMargin = 20.0;
    // Desired horizontal margin for the dialog
    const double horizontalDialogScreenMargin = 20.0;

    // This outer Padding widget is crucial.
    // It defines the space WHERE THE DIALOG (Material widget) WILL BE PLACED.
    // - top: Accounts for status bar + desired margin.
    // - bottom: Accounts for keyboard height + desired margin. This effectively
    //           pushes the dialog up when the keyboard appears, reducing the
    //           vertical space available to the dialog.
    // - left/right: Horizontal margins for the dialog.
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalDialogScreenMargin,
        right: horizontalDialogScreenMargin,
        top: topSystemPadding + verticalDialogScreenMargin,
        bottom: keyboardHeight + verticalDialogScreenMargin,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        clipBehavior: Clip.antiAlias, // Ensures content respects border radius
        child: SingleChildScrollView(
          // This SingleChildScrollView makes the *content inside the Material dialog* scrollable.
          // Its viewport height is determined by the space left for the Material widget
          // by the outer Padding.

          controller: _scrollController,
          padding: const EdgeInsets.all(4.0), // Internal padding for the dialog's content
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog content takes minimum necessary height
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the status being replied to
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest, // A subtle background
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: MastodonStatusCardBody(
                        status: _effectiveStatus,
                        originalStatus: widget.status, // Pass the original for reblog info
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Compose area using SharedComposeWidget
                    SharedComposeWidget(
                      taggerController: _replyTaggerController,
                      focusNode: _focusNode,
                      hintText: "Your reply...",
                      minLines: 4, // A good default for reply boxes
                      maxLines: 8, // Allows for longer replies with internal scrolling
                    ),
                    const SizedBox(height: 16.0),
                  ])),

              // Action button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.reply),
                    label: const Text("Reply"),
                    onPressed: () {
                      final replyText = _replyTaggerController.text.trim();
                      // Ensure reply is not empty and actually different from just prefilled mentions
                      if (replyText.isNotEmpty && replyText != _effectiveStatus.replyMentions().join(' ').trim()) {
                        MastodonStatusRepository.replyToStatus(_effectiveStatus.id, replyText);
                        Navigator.of(context).pop(); // Close dialog on successful reply
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Replied!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reply cannot be empty.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

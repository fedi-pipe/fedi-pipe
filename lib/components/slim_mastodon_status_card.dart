import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/components/mastodon_profile_bottom_sheet.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class SlimMastodonStatusCard extends StatelessWidget {
  final MastodonStatusModel status;

  const SlimMastodonStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final MastodonStatusModel displayStatus = status.reblog ?? status;
    final bool isReblog = status.reblog != null;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0), // Minimal margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5)
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'statusDetail',
            pathParameters: {'id': displayStatus.id},
            extra: displayStatus,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReblog)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        "${status.account.displayName} boosted",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => showMastodonProfileBottomSheet(context, displayStatus.account),
                    child: CircleAvatar(
                      radius: 18, // Smaller avatar
                      backgroundImage: NetworkImage(displayStatus.account.avatar ?? ''),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayStatus.account.displayName ?? displayStatus.account.username,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "@${displayStatus.account.acct}",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          timeago.format(DateTime.parse(displayStatus.createdAt)),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              if (displayStatus.content.isNotEmpty)
                HtmlRenderer(
                  html: displayStatus.content, // Consider a way to truncate or limit lines if needed
                  onMentionTapped: (acctIdentifier) {
                     showMastodonProfileBottomSheetWithLoading(context, acctIdentifier);
                  },
                ),
              // Optionally, add indicators for media attachments if needed (e.g., a small icon)
              if (displayStatus.mediaAttachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        displayStatus.mediaAttachments.first.type == 'video' ? Icons.videocam_outlined :
                        displayStatus.mediaAttachments.first.type == 'gifv' ? Icons.gif_box_outlined :
                        displayStatus.mediaAttachments.first.type == 'audio' ? Icons.audiotrack_outlined :
                        Icons.image_outlined,
                        size: 16, color: Colors.grey[700]),
                      if (displayStatus.mediaAttachments.length > 1)
                        Text(" +${displayStatus.mediaAttachments.length - 1}", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700])),
                    ],
                  ),
                ),
              if (displayStatus.card != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 4.0),
                   child: Row(
                     children: [
                       Icon(Icons.link_outlined, size: 16, color: Colors.grey[700]),
                       SizedBox(width: 4),
                       Expanded(
                         child: Text(
                            displayStatus.card!.title?.isNotEmpty == true ? displayStatus.card!.title! : displayStatus.card!.url ?? 'Link',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                         ),
                       ),
                     ],
                   ),
                 )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:fedi_pipe/models/grouped_notification_item.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/profile_page.dart'; // For navigating to profile
import 'package:flutter/material.dart';
import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/components/mastodon_status_card.dart'; // For potential reuse or inspiration
import 'package:timeago/timeago.dart' as timeago;

class GroupedNotificationCard extends StatelessWidget {
  final GroupedNotificationItem item;

  const GroupedNotificationCard({Key? key, required this.item}) : super(key: key);

  IconData _getIconForType(String type) {
    switch (type) {
      case 'favourite':
        return Icons.favorite;
      case 'reblog':
        return Icons.repeat;
      case 'mention':
        return Icons.alternate_email;
      case 'follow':
        return Icons.person_add;
      case 'poll':
        return Icons.poll;
      case 'update':
        return Icons.edit_note;
      default:
        return Icons.notifications;
    }
  }

  String _buildActionText() {
    final count = item.accounts.length;
    final firstAccountName = item.accounts.first.displayName.isNotEmpty 
                             ? item.accounts.first.displayName 
                             : item.accounts.first.username;

    String actionVerb = '';
    switch (item.primaryType) {
      case 'favourite':
        actionVerb = count > 1 ? 'favourited' : 'favourited';
        break;
      case 'reblog':
        actionVerb = count > 1 ? 'reblogged' : 'reblogged';
        break;
      case 'follow':
        actionVerb = count > 1 ? 'followed you' : 'followed you';
        return count > 1 
            ? '${item.accounts.take(2).map((a) => a.displayName.isNotEmpty ? a.displayName : a.username).join(', ')}${count > 2 ? ' and ${count - 2} others' : ''} $actionVerb'
            : '$firstAccountName $actionVerb';
      case 'mention':
        return '${item.representativeAccount.displayName} mentioned you';
      case 'poll':
        return 'A poll you participated in has ended';
      case 'update':
        return '${item.representativeAccount.displayName} edited a status';
      default:
        actionVerb = 'interacted with';
    }

    if (count == 1) {
      return '$firstAccountName $actionVerb your status';
    } else if (count == 2) {
      final secondAccountName = item.accounts[1].displayName.isNotEmpty
                                ? item.accounts[1].displayName
                                : item.accounts[1].username;
      return '$firstAccountName and $secondAccountName $actionVerb your status';
    } else {
      return '$firstAccountName, ${item.accounts[1].displayName.isNotEmpty ? item.accounts[1].displayName : item.accounts[1].username} and ${count - 2} others $actionVerb your status';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(item.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_getIconForType(item.primaryType), color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.accounts.isNotEmpty) // Ensure accounts list is not empty
                        Wrap( // Use Wrap for avatars to handle overflow if many
                          spacing: -8.0, // Negative spacing for overlap
                          children: item.accounts.take(3).map((account) { // Show up to 3 avatars
                            return GestureDetector(
                               onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ProfilePage(initialAccount: account),
                                ));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(account.avatar ?? ''),
                                radius: 14,
                                backgroundColor: Colors.grey[300],
                              ),
                            );
                          }).toList(),
                        ),
                      if (item.accounts.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        _buildActionText(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.status != null && (item.primaryType == 'mention' || item.primaryType == 'favourite' || item.primaryType == 'reblog' || item.primaryType == 'update' || item.primaryType == 'poll'))
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 40), // Indent status preview
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest, // Slightly different background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Display the status content using HtmlRenderer if content is not empty
                      if (item.status!.content.isNotEmpty)
                        HtmlRenderer(html: item.status!.content),
                      // Display media attachments if any
                      if (item.status!.mediaAttachments.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: AttachmentRenderer(status: item.status!), // Reusing AttachmentRenderer
                        ),
                      if (item.status!.card != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: MastodonStatusCard(status: item.status!).buildCard(item.status!.card!) // Assuming buildCard is public or refactor
                         )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extension to make buildCard accessible (or move buildCard to a utility)
extension MastodonStatusCardHelper on MastodonStatusCard {
  Widget buildCard(MastodonCardModel card) {
    // This is a simplified copy of _renderCard from MastodonStatusCard.
    // Ideally, _renderCard would be a static method or a separate widget.
    return Builder(builder: (context) { // Use Builder to get context if needed for Theme, etc.
      return GestureDetector(
        onTap: () {
          final uri = Uri.parse(card.url!);
          launchUrl(uri); // Make sure url_launcher is imported
        },
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero, // Adjust margin as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make image stretch
            children: [
              if (card.image != null && card.image!.isNotEmpty)
                Image.network(
                  card.image!,
                  height: 150, // Fixed height for consistency
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      Container(height:150, color: Colors.grey[200], child: Icon(Icons.broken_image)),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     if (card.title != null && card.title!.isNotEmpty)
                      Text(
                        card.title!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (card.description != null && card.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          card.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (card.url != null && Uri.tryParse(card.url!)?.host != null)
                       Padding(
                         padding: const EdgeInsets.only(top: 4.0),
                         child: Text(
                           Uri.parse(card.url!).host,
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

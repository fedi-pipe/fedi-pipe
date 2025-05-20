import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';

class GroupedNotificationItem {
  // A key to uniquely identify this group, can be composite (e.g., "favourite-[status_id]")
  final String displayGroupKey;
  // The primary type of notification in this group (e.g., "favourite", "reblog", "mention", "follow")
  final String primaryType;
  // The target status, if the notification is about a status (e.g., for favourites, reblogs, mentions)
  final MastodonStatusModel? status;
  // List of accounts that contributed to this grouped notification
  // e.g., multiple users who favourited/reblogged the same post
  final List<MastodonAccountModel> accounts;
  final MastodonAccountModel? singleAccount; // Ensure this field is present
  final MastodonNotificationModel latestNotificationInGroup;
  // List of all original notifications that form this group, if needed for detailed expansion
  final List<MastodonNotificationModel> originalNotifications;

  GroupedNotificationItem({
    required this.displayGroupKey,
    required this.primaryType,
    this.status,
    required this.accounts,
    this.singleAccount, // Make sure this line is in your constructor
    required this.originalNotifications,
  });

  // Helper to get the most recent creation date for sorting or display
  DateTime get createdAt => DateTime.parse(latestNotificationInGroup.createdAt as String);

  // Updated getter for clarity, ensuring it uses the singleAccount if available.
  MastodonAccountModel get representativeAccount => singleAccount ?? accounts.first;
}

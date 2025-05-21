import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';

class GroupedNotificationItem {
  final String displayGroupKey;
  final String primaryType;
  final MastodonStatusModel? status;
  final List<MastodonAccountModel> accounts;
  final MastodonAccountModel? singleAccount;
  final MastodonNotificationModel latestNotificationInGroup; // Field is present
  final List<MastodonNotificationModel> originalNotifications;

  GroupedNotificationItem({
    required this.displayGroupKey,
    required this.primaryType,
    this.status,
    required this.accounts,
    this.singleAccount,
    required this.latestNotificationInGroup, // <<< MAKE SURE THIS LINE IS PRESENT
    required this.originalNotifications,
  });

  DateTime get createdAt => DateTime.parse(latestNotificationInGroup.createdAt as String);
  MastodonAccountModel get representativeAccount => singleAccount ?? accounts.first;
}


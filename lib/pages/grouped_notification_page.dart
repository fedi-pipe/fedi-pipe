import 'package:fedi_pipe/components/default_layout.dart';
import 'package:fedi_pipe/models/grouped_notification_item.dart';
import 'package:fedi_pipe/models/mastodon_notification.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/notification_repository.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

// (You will need to create GroupedNotificationCard widget separately)
import 'package:fedi_pipe/components/grouped_notification_card.dart';

class GroupedNotificationPage extends StatefulWidget {
  const GroupedNotificationPage({Key? key}) : super(key: key);

  @override
  State<GroupedNotificationPage> createState() => _GroupedNotificationPageState();
}

class _GroupedNotificationPageState extends State<GroupedNotificationPage> {
  List<GroupedNotificationItem> _groupedNotifications = [];
  bool _isLoading = false;
  String? _error;

  // For pagination (optional for notifications, but good for consistency)
  String? _maxId; // For fetching older notifications
  String? _sinceId; // For fetching newer notifications (used by refresh)

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAndGroupNotifications(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _fetchAndGroupNotifications(maxId: _maxId);
    }
  }

  Future<void> _fetchAndGroupNotifications({bool isRefresh = false, String? maxId, String? sinceId}) async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        if (isRefresh) {
           _sinceId = _groupedNotifications.isNotEmpty ? _groupedNotifications.first.latestNotificationInGroup.id : null;
        }
      });
    }
    
    // If refreshing, we want to get notifications newer than the newest one we have.
    // If paginating (maxId is provided), we get older notifications.
    String? currentSinceId = isRefresh ? _sinceId : null;
    String? currentMaxId = isRefresh ? null : (maxId ?? _maxId);


    try {
      List<MastodonNotificationModel> fetchedNotifications = await MastodonNotificationRepository.fetchNotifications(
        limit: 40, // Fetch a decent batch
        excludeTypes: ['follow_request', 'poll', 'update', 'admin.sign_up', 'admin.report'], // Common exclusions
        previousId: currentMaxId, // For "load older"
        nextId: currentSinceId,    // For "load newer" on refresh
      );

      if (mounted) {
        setState(() {
          List<MastodonNotificationModel> allNotifications;
          if (isRefresh) {
            // Prepend new notifications and keep existing ones that are not in the new batch
            final newNotificationIds = fetchedNotifications.map((n) => n.id).toSet();
            allNotifications = [...fetchedNotifications, ..._groupedNotifications.expand((group) => group.originalNotifications).where((n) => !newNotificationIds.contains(n.id))];
          } else if (maxId != null) { // Loading older
            allNotifications = [..._groupedNotifications.expand((group) => group.originalNotifications), ...fetchedNotifications];
          } else { // Default initial load (should be covered by isRefresh true)
            allNotifications = fetchedNotifications;
          }
          
          // Deduplicate just in case
          final uniqueNotifications = LinkedHashMap<String, MastodonNotificationModel>.fromIterable(
            allNotifications,
            key: (item) => item.id,
            value: (item) => item,
          ).values.toList();

          // Update pagination markers
          if (fetchedNotifications.isNotEmpty) {
            if (isRefresh || sinceId != null) { // Fetched newer
                // _sinceId is already set or could be fetchedNotifications.first.id if needed for next refresh
            }
            if (maxId != null || !isRefresh) { // Fetched older or initial full load
                _maxId = fetchedNotifications.last.id;
            }
             if (isRefresh && fetchedNotifications.isNotEmpty) {
                _sinceId = fetchedNotifications.first.id; // Update sinceId for next pull to refresh
            }
          }


          _groupNotifications(uniqueNotifications);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          print("Error fetching notifications: $e");
        });
      }
    }
  }

  void _groupNotifications(List<MastodonNotificationModel> notifications) {
    final grouped = <String, List<MastodonNotificationModel>>{};

    for (var n in notifications) {
      String key;
      if ((n.type == 'favourite' || n.type == 'reblog') && n.status != null) {
        key = '${n.type}-${n.status!.id}';
      } else if (n.type == 'follow') {
        key = 'follow-${n.account.id}'; // Group follows by the account being followed (you) or by the follower
                                        // For "you are followed by X", group by "follow-YOUR_ID-X.account.id" might be too granular
                                        // For now, let's treat follows as individual unless many from same person (which API usually doesn't give)
                                        // The provided `group_key` from API for follow is 'follow-[follower_id]'
                                        // If we want to group "X, Y, Z followed you", we need a different strategy or rely on server grouping.
                                        // For now, using the API's groupKey for follows and mentions if it makes sense.
        key = n.groupKey ?? 'ungrouped-${n.id}'; // Fallback to API's group key or individual
      } else if (n.type == 'mention' && n.status != null) {
         key = n.groupKey ?? 'mention-${n.id}'; // Mentions are usually individual
      }
      else {
        key = n.groupKey ?? 'ungrouped-${n.id}'; // Fallback for other types or if groupKey is null
      }
      grouped.putIfAbsent(key, () => []).add(n);
    }

    final List<GroupedNotificationItem> result = [];
    grouped.forEach((key, group) {
      if (group.isEmpty) return;

      group.sort((a, b) => DateTime.parse(b.createdAt as String).compareTo(DateTime.parse(a.createdAt as String)));
      final latestNotification = group.first;
      final accounts = group.map((n) => n.account).toList();
      // Simple de-duplication of accounts for display
      final uniqueAccounts = LinkedHashMap<String, MastodonAccountModel>.fromIterable(
        accounts, key: (acc) => acc.id, value: (acc) => acc
      ).values.toList();


      result.add(GroupedNotificationItem(
        displayGroupKey: key,
        primaryType: latestNotification.type,
        status: latestNotification.status,
        accounts: uniqueAccounts,
        latestNotificationInGroup: latestNotification,
        originalNotifications: group,
        singleAccount: latestNotification.type == 'mention' || latestNotification.type == 'follow' ? latestNotification.account : null,
      ));
    });

    // Sort final grouped items by the most recent notification in each group
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _groupedNotifications = result;
  }


  Widget _buildNotificationList() {
    if (_groupedNotifications.isEmpty) {
       if (_isLoading) { // Initial load handled by RefreshIndicator's spinner
         return ListView( physics: const AlwaysScrollableScrollPhysics()); // Needs to be scrollable
       }
      return LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(child: Text(_error ?? 'No notifications yet. Pull to refresh!'))));
      });
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: _groupedNotifications.length + (_isLoading && _maxId != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _groupedNotifications.length) {
          final item = _groupedNotifications[index];
          return GroupedNotificationCard(key: ValueKey(item.displayGroupKey), item: item);
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'Notifications',
      body: RefreshIndicator(
        onRefresh: () => _fetchAndGroupNotifications(isRefresh: true),
        child: _buildNotificationList(),
      ),
    );
  }
}

import 'package:fedi_pipe/models/mastodon_status.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';

class SearchResultView extends StatelessWidget {
  final List<MastodonAccountModel> accounts;
  final Function(MastodonAccountModel) onTap;

  // You can adjust these constants to control the appearance and behavior:
  /// Approximate height of a single ListTile.
  /// Standard ListTiles are around 56.0, but this can vary with content, density, etc.
  /// Adjust if your ListTiles are consistently taller or shorter.
  static const double _estimatedItemHeight = 58.0; // Adjusted for slightly more padding in ListTile

  /// Maximum number of items to display before the list becomes scrollable.
  static const int _maxVisibleItemsBeforeScroll = 4;

  const SearchResultView({
    Key? key,
    required this.accounts,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the maxHeight for the suggestions box.
    // This allows the box to show up to `_maxVisibleItemsBeforeScroll` items
    // without internal scrolling, and then scroll for more items.
    final calculatedMaxHeight = _maxVisibleItemsBeforeScroll * _estimatedItemHeight;

    // If there are no accounts, we don't want to show an empty box.
    // SharedComposeWidget should ideally handle not showing the overlay if accounts is empty,
    // but this is a safeguard for SearchResultView itself.
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Consistent rounded corners
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects the rounded corners
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh, // Elevated surface color
        constraints: BoxConstraints(
          // The container will be at most this tall.
          maxHeight: calculatedMaxHeight,
          // It can be shorter if the content is less, due to ListView's shrinkWrap.
          minHeight: 0, // Allow it to shrink completely if needed (though handled by isEmpty check above)
        ),
        child: Scrollbar( // Added Scrollbar
          thumbVisibility: true, // Make scrollbar thumb visible when scrolling
          child: ListView.builder(
          shrinkWrap:
              true, // THIS IS KEY: Makes ListView take up only necessary vertical space for its items, up to the parent's constraints.
          padding: const EdgeInsets.symmetric(vertical: 6.0), // Padding for the list itself
          itemCount: accounts.length,
          // Consider using itemExtent if all your ListTiles have a guaranteed fixed height.
          // This can improve scroll performance for very long lists, but for a few suggestion items,
          // dynamic height is usually fine.
          // itemExtent: _estimatedItemHeight,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 20.0, // Standard avatar size
                backgroundImage: (account.avatar != null && account.avatar!.isNotEmpty)
                    ? NetworkImage(account.avatar!)
                    : null,
                onBackgroundImageError: (account.avatar != null && account.avatar!.isNotEmpty) ? (_, __) {} : null,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: (account.avatar == null || account.avatar!.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 22, // Adjust icon size to fit CircleAvatar
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      )
                    : null,
              ),
              title: Text(
                account.displayName ?? account.username,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '@${account.acct ?? account.username}',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onTap(account),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Adjusted padding
            );
          },
        ),
      ),
    );
  }
}


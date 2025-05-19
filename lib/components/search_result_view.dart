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
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentPreferredMaxHeight = _maxVisibleItemsBeforeScroll * _estimatedItemHeight;
        final double parentProvidedMaxHeight = constraints.hasBoundedHeight 
                                               ? constraints.maxHeight 
                                               : contentPreferredMaxHeight;
        final double actualMaxHeight = (contentPreferredMaxHeight < parentProvidedMaxHeight)
                                      ? contentPreferredMaxHeight
                                      : parentProvidedMaxHeight;

        return Material(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: actualMaxHeight,
              minHeight: 0,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    leading: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: (account.avatar != null && account.avatar!.isNotEmpty)
                          ? NetworkImage(account.avatar!)
                          : null,
                      onBackgroundImageError: (account.avatar != null && account.avatar!.isNotEmpty) ? (_, __) {} : null,
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: (account.avatar == null || account.avatar!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 22,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '@${account.acct ?? account.username}',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onTap(account),
                  );
                },
              ),
            ),
          ),
        );
      }
    );
  }
}

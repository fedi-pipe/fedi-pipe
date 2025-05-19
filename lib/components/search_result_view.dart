import 'package:fedi_pipe/models/mastodon_status.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';

class SearchResultView extends StatelessWidget {
  final List<MastodonAccountModel> accounts;
  final Function(MastodonAccountModel) onTap;

  // Configuration for the view's size
  static const double _estimatedItemHeight = 58.0; // Approximate height of a ListTile with some padding
  static const int _maxVisibleItemsBeforeScroll = 3; // Max items to show before the list scrolls

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

    // This LayoutBuilder will get the constraints from the parent (FlutterTagger's overlay slot)
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Max height available from parent (e.g., FlutterTagger's overlay positioning)
        final double parentProvidedMaxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : (_maxVisibleItemsBeforeScroll * _estimatedItemHeight); // Fallback if parent is unconstrained

        // The actual maxHeight for our view should be the minimum of:
        // 1. The height preferred by our content (e.g., up to _maxVisibleItemsBeforeScroll items).
        // 2. The max height actually allowed by the parent/overlay slot.
        final double contentPreferredMaxHeight = _maxVisibleItemsBeforeScroll * _estimatedItemHeight;
        final double actualMaxHeight =
            (contentPreferredMaxHeight < parentProvidedMaxHeight) ? contentPreferredMaxHeight : parentProvidedMaxHeight;

        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding to separate from the text field
            child: Material(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).colorScheme.surfaceContainerHigh, // Use a distinct overlay color
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin to separate from the text field
                  constraints: BoxConstraints(
                    maxHeight: actualMaxHeight, // Apply the dynamically determined maxHeight
                    minHeight: 0, // Can be very short if only one item and actualMaxHeight allows
                  ),
                  child: Scrollbar(
                    thumbVisibility: true, // Show scrollbar when scrollable
                    child: ListView.builder(
                      shrinkWrap: true, // Crucial for fitting content up to maxHeight
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
                            onBackgroundImageError:
                                (account.avatar != null && account.avatar!.isNotEmpty) ? (_, __) {} : null,
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
                )));
      },
    );
  }
}

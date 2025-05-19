// lib/components/search_result_view.dart
import 'package:fedi_pipe/models/mastodon_status.dart'; // Ensure this path is correct for MastodonAccountModel
import 'package:flutter/material.dart';

class SearchResultView extends StatelessWidget {
  final List<MastodonAccountModel> accounts;
  final Function(MastodonAccountModel) onTap;

  const SearchResultView({
    Key? key,
    required this.accounts,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using Material to ensure proper theming (e.g., for ListTile)
    // and to provide a distinct visual layer when used as an overlay.
    return Material(
      elevation: 4.0, // Standard elevation for overlays like pop-ups or dropdowns.
      shape: RoundedRectangleBorder(
        // Optional: if you want rounded corners for the overlay box
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        // Use a theme-aware color for the background.
        // cardColor is often suitable for overlay elements.
        color: Theme.of(context).cardColor,
        constraints: const BoxConstraints(maxHeight: 220), // Limit the height of the suggestions box.
        // Adjust as needed, e.g., to show 3-4 items without scrolling.
        child: ListView.builder(
          shrinkWrap: true, // Important for use in overlays or constrained spaces.
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (account.avatar != null && account.avatar!.isNotEmpty)
                    ? NetworkImage(account.avatar!)
                    : null, // NetworkImage will handle null; CircleAvatar shows fallback.
                onBackgroundImageError: (account.avatar != null && account.avatar!.isNotEmpty)
                    ? (_, __) {}
                    : null, // Suppress errors for valid attempts
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Fallback background
                child: (account.avatar == null || account.avatar!.isEmpty)
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ) // Fallback icon
                    : null,
              ),
              title: Text(
                account.displayName ?? account.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '@${account.acct ?? account.username}', // Fallback to username if acct is null
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onTap(account),
            );
          },
        ),
      ),
    );
  }
}

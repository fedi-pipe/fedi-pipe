import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/profile_page.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';

import 'package:fedi_pipe/components/skeletons/profile_skeleton.dart';

// Function to show the bottom sheet when account data needs to be loaded via acctIdentifier
void showMastodonProfileBottomSheetWithLoading(BuildContext context, String acct) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up more screen height if needed
    backgroundColor: Colors.transparent, // Makes the default sheet background transparent
    builder: (context) {
      // MastodonProfileBottomSheet will handle its own loading state
      return MastodonProfileBottomSheet(acctIdentifier: acct);
    },
  );
}

// Function to show the bottom sheet when MastodonAccountModel is already available
void showMastodonProfileBottomSheet(BuildContext context, MastodonAccountModel account) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MastodonProfileBottomSheet(initialAccount: account);
    },
  );
}

class MastodonProfileBottomSheet extends StatefulWidget {
  final MastodonAccountModel? initialAccount;
  final String? acctIdentifier;

  const MastodonProfileBottomSheet({
    super.key,
    this.initialAccount,
    this.acctIdentifier,
  }) : assert(initialAccount != null || acctIdentifier != null,
            'Either initialAccount or acctIdentifier must be provided');

  @override
  State<MastodonProfileBottomSheet> createState() => _MastodonProfileBottomSheetState();
}

class _MastodonProfileBottomSheetState extends State<MastodonProfileBottomSheet> {
  MastodonAccountModel? _account;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialAccount != null) {
      _account = widget.initialAccount;
      _isLoading = false;
    } else if (widget.acctIdentifier != null) {
      _fetchAccountDetails();
    } else {
      // This case should ideally not be reached due to the assertion
      // in the widget's constructor.
      _isLoading = false;
      _error = "No account information provided.";
    }
  }

  Future<void> _fetchAccountDetails() async {
    if (widget.acctIdentifier == null) return;
    // Ensure loading state is set if fetching
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final accountData = await MastodonAccountRepository.lookUpAccount(widget.acctIdentifier!);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _account = accountData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Check again
        setState(() {
          _error = "Failed to load profile: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading) {
      content = MastodonProfileSkeleton(isBottomSheet: true);
    } else if (_error != null) {
      content = Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text(_error!, textAlign: TextAlign.center)),
      );
    } else if (_account == null) {
      content = Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text('Profile data not available.')),
      );
    } else {
      // If account data is available, render the actual profile content
      final currentAccount = _account!;
      content = SingleChildScrollView(
        // Make content scrollable if it overflows
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header (Avatar, Name, Acct)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                    // Navigate to the full profile page
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => ProfilePage(initialAccount: currentAccount)));
                  },
                  child: CircleAvatar(
                    radius: 30, // Avatar size
                    backgroundImage: currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty
                        ? NetworkImage(currentAccount.avatar!)
                        : null,
                    onBackgroundImageError: currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty
                        ? (_, __) {} // Placeholder for error, or a default icon
                        : null,
                    child: (currentAccount.avatar == null || currentAccount.avatar!.isEmpty)
                        ? Icon(Icons.person, size: 30) // Default icon if no avatar
                        : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentAccount.displayName ?? currentAccount.username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentAccount.acct != null)
                        Text(
                          "@${currentAccount.acct}",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Optional: Add a follow/more_options button here if needed
              ],
            ),
            SizedBox(height: 16),

            // Profile Note/Bio
            if (currentAccount.note != null && currentAccount.note!.isNotEmpty)
              HtmlRenderer(
                html: currentAccount.note!,
                onMentionTapped: (acctIdentifier) {
                  // If the tapped mention is the current profile, just close the sheet.
                  if (acctIdentifier == currentAccount.acct || "@${acctIdentifier}" == currentAccount.acct) {
                    Navigator.of(context).pop();
                    return;
                  }
                  Navigator.of(context).pop(); // Close current bottom sheet
                  // Navigate to ProfilePage, which will handle its own loading skeleton
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(acctIdentifier: acctIdentifier),
                  ));
                },
              )
            else
              Padding(
                // Added padding for "No bio" text for better spacing
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:
                    Text("No bio available.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
              ),
            SizedBox(height: 16),

            // Profile Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, "Followers", currentAccount.followersCount),
                _buildStatItem(context, "Following", currentAccount.followingCount),
                _buildStatItem(context, "Posts", currentAccount.statusesCount),
              ],
            ),
            SizedBox(height: 16), // Padding at the bottom
          ],
        ),
      );
    }

    // Outer container for the bottom sheet's shape and padding
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20), // Rounded corners for the sheet
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: Theme.of(context).cardColor, // Use themed card color for background
        padding: EdgeInsets.only(
            top: 20, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16 // Adjust for keyboard
            ),
        constraints: BoxConstraints(
          // Set max height for the sheet
          maxHeight: MediaQuery.of(context).size.height * 0.75, // Example: 75% of screen height
        ),
        child: content, // The actual content (skeleton or profile data)
      ),
    );
  }

  // Helper widget to build individual stat items (Followers, Following, Posts)
  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2), // Reduced space
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}


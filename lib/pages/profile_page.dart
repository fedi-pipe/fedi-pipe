import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';

import 'package:fedi_pipe/components/skeletons/profile_skeleton.dart';

class ProfilePage extends StatefulWidget {
  final MastodonAccountModel? initialAccount;
  final String? acctIdentifier;

  const ProfilePage({
    super.key,
    this.initialAccount,
    this.acctIdentifier,
  }) : assert(initialAccount != null || acctIdentifier != null,
            'Either initialAccount or acctIdentifier must be provided');

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    // Set initial loading state if not already set by initialAccount
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final account = await MastodonAccountRepository.lookUpAccount(widget.acctIdentifier!);
      if (mounted) {
        // Check again before setting state
        setState(() {
          _account = account;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading
            ? 'Loading Profile...'
            : (_error != null ? 'Error' : (_account?.displayName ?? _account?.username ?? 'Profile'))),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return MastodonProfileSkeleton(isBottomSheet: false);
    }
    // Error display should come after loading check
    if (_error != null) {
      return Center(
          child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, textAlign: TextAlign.center)));
    }
    // Check for account null after error and loading
    if (_account == null) {
      // This could happen if initialAccount and acctIdentifier were both null,
      // and _fetchAccountDetails wasn't called or failed silently before setting error.
      // Or if fetch completed but account was still null (API returned null).
      return Center(child: Text('Profile data not available.'));
    }

    // If we've reached here, _account is not null, not loading, and no error.
    final currentAccount = _account!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image
          if (currentAccount.header != null && currentAccount.header!.isNotEmpty)
            Image.network(
              currentAccount.header!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                );
              },
            )
          else
            Container(
                width: double.infinity, height: 150, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),

          // Profile Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -60),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty
                              ? NetworkImage(currentAccount.avatar!)
                              : null,
                          onBackgroundImageError:
                              currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty ? (_, __) {} : null,
                          child: currentAccount.avatar == null || currentAccount.avatar!.isEmpty
                              ? Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      icon: Icon(Icons.person_add_outlined),
                      label: Text("Follow"),
                      onPressed: () {/* TODO: Implement follow functionality */},
                    ),
                  ],
                ),
                SizedBox(height: 8), // Adjust space after avatar row

                // Usernames and Display Name
                Text(
                  currentAccount.displayName ?? currentAccount.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentAccount.acct != null)
                  Text(
                    "@${currentAccount.acct}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                SizedBox(height: 16),

                // User Note/Bio
                if (currentAccount.note != null && currentAccount.note!.isNotEmpty)
                  HtmlRenderer(
                    html: currentAccount.note!,
                    onMentionTapped: (acctIdentifier) {
                      if (acctIdentifier == currentAccount.acct || "@${acctIdentifier}" == currentAccount.acct) {
                        return; // Do nothing if it's the same profile
                      }
                      // Navigate to a new ProfilePage, which will handle its own loading
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfilePage(acctIdentifier: acctIdentifier),
                      ));
                    },
                  )
                else
                  Text(
                    "No bio available.",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                SizedBox(height: 24),

                // User Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, "Followers", currentAccount.followersCount),
                    _buildStatItem(context, "Following", currentAccount.followingCount),
                    _buildStatItem(context, "Posts", currentAccount.statusesCount),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}


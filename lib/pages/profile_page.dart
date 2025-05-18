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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Loading Profile...' : (_error != null ? 'Error' : (_account?.displayName ?? _account?.username ?? 'Profile'))
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return MastodonProfileSkeleton(isBottomSheet: false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load profile: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
    if (_error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, textAlign: TextAlign.center)));
    }
    if (_account == null) {
      return Center(child: Text('Profile data not available.'));
    }

    final currentAccount = _account!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            Container(width: double.infinity, height: 150, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),

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
                          onBackgroundImageError: currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty ? (_, __) {} : null,
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
                      onPressed: () { /* TODO */ },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  currentAccount.displayName ?? currentAccount.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (currentAccount.acct != null)
                  Text("@${currentAccount.acct}", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                SizedBox(height: 16),
                if (currentAccount.note != null && currentAccount.note!.isNotEmpty)
                  HtmlRenderer(
                    html: currentAccount.note!,
                    onMentionTapped: (acctIdentifier) {
                      if (acctIdentifier == currentAccount.acct || "@${acctIdentifier}" == currentAccount.acct) {
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfilePage(acctIdentifier: acctIdentifier),
                      ));
                    },
                  )
                else
                  Text("No bio available.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                SizedBox(height: 24),
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
      _isLoading = false;
      _error = "No account information provided.";
    }
  }

  Future<void> _fetchAccountDetails() async {
    if (widget.acctIdentifier == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final account = await MastodonAccountRepository.lookUpAccount(widget.acctIdentifier!);
      if (mounted) {
        setState(() {
          _account = account;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load profile: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

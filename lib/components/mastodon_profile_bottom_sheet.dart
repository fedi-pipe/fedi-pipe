import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/profile_page.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';

import 'package:fedi_pipe/components/skeletons/profile_skeleton.dart';

void showMastodonProfileBottomSheetWithLoading(BuildContext context, String acct) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MastodonProfileBottomSheet(acctIdentifier: acct);
    },
  );
}

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
      final accountData = await MastodonAccountRepository.lookUpAccount(widget.acctIdentifier!);
      if (mounted) {
        setState(() {
          _account = accountData;
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
      final currentAccount = _account!;
      content = SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(initialAccount: currentAccount)));
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(currentAccount.avatar ?? ''),
                    onBackgroundImageError: (_, __) {},
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
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      if (currentAccount.acct != null)
                        Text("@${currentAccount.acct}", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                           maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (currentAccount.note != null && currentAccount.note!.isNotEmpty)
              HtmlRenderer(
                html: currentAccount.note!,
                onMentionTapped: (acctIdentifier) {
                  if (acctIdentifier == currentAccount.acct || "@${acctIdentifier}" == currentAccount.acct) {
                     Navigator.of(context).pop();
                     return;
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(acctIdentifier: acctIdentifier),
                  ));
                },
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, "Followers", currentAccount.followersCount),
                _buildStatItem(context, "Following", currentAccount.followingCount),
                _buildStatItem(context, "Posts", currentAccount.statusesCount),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: content,
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(account: account)));
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(account.avatar!),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      account.acct!,
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (account.note != null && account.note!.isNotEmpty)
            HtmlRenderer(
              html: account.note!,
              onMentionTapped: (String acctIdentifier) {
                if (acctIdentifier == account.acct || "@${acctIdentifier}" == account.acct) {
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return Center(child: CircularProgressIndicator());
                  },
                );

                MastodonAccountRepository.lookUpAccount(acctIdentifier).then((mentionedAccount) {
                  Navigator.of(context).pop();

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext navContext) => ProfilePage(account: mentionedAccount),
                  ));
                }).catchError((error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not load profile for @$acctIdentifier. Error: $error")),
                  );
                });
              },
            ),
          SizedBox(height: 16),
        ]),
      ),
    );
  }
}

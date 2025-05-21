import 'package:fedi_pipe/components/html_renderer.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:fedi_pipe/components/skeletons/profile_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

// Placeholders for UserPostsFeed, UserRepliesFeed, UserMediaFeed remain the same
class UserPostsFeed extends StatelessWidget {
  final String accountId;
  const UserPostsFeed({super.key, required this.accountId});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text('Posts by $accountId (To be implemented)',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      );
}
class UserRepliesFeed extends StatelessWidget {
  final String accountId;
  const UserRepliesFeed({super.key, required this.accountId});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text('Replies by $accountId (To be implemented)',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      );
}
class UserMediaFeed extends StatelessWidget {
  final String accountId;
  const UserMediaFeed({super.key, required this.accountId});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text('Media by $accountId (To be implemented)',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
      );
}


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

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  MastodonAccountModel? _account;
  bool _isLoading = true;
  String? _error;
  TabController? _tabController;

  // Define sizes for the avatar when it's part of the header
  static const double _headerAvatarRadius = 50.0; 
  static const double _headerAvatarBorderWidth = 3.0;
  // Calculate expanded height for SliverAppBar: Avatar diameter + top/bottom padding for avatar + space for name/acct if also in header
  static const double _sliverAppBarExpandedHeight = (_headerAvatarRadius + _headerAvatarBorderWidth) * 2 + 64.0; // Diameter + 32px vertical padding total


  @override
  void initState() {
    super.initState();
    if (widget.initialAccount != null) {
      _account = widget.initialAccount;
      _isLoading = false;
      _setupTabController();
    } else if (widget.acctIdentifier != null) {
      _fetchAccountDetails();
    } else {
      _isLoading = false;
      _error = "No account information provided.";
    }
  }

  void _setupTabController() {
    if (_account != null && mounted) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchAccountDetails() async {
    if (widget.acctIdentifier == null) return;
    if (mounted) {
      setState(() { _isLoading = true; _error = null; });
    }
    try {
      final account = await MastodonAccountRepository.lookUpAccount(widget.acctIdentifier!);
      if (mounted) {
        setState(() { _account = account; _isLoading = false; _setupTabController(); });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = "Failed to load profile: ${e.toString()}"; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? MastodonProfileSkeleton(isBottomSheet: false)
          : _error != null
              ? _buildErrorView()
              : _account == null
                  ? _buildErrorView(message: 'Profile data not available.')
                  : _buildProfileView(),
    );
  }

 Widget _buildErrorView({String? message}) {
    final theme = Theme.of(context);
    return Center( /* ... Error view code remains the same ... */ );
  }

  Widget _buildProfileView() {
    final currentAccount = _account!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: _sliverAppBarExpandedHeight,
              pinned: true,
              floating: false,
              stretch: false, // Can be true if you want stretch effect
              backgroundColor: colorScheme.surface, // Background when collapsed or if flexible space is transparent
              foregroundColor: colorScheme.onSurface,
              elevation: innerBoxIsScrolled ? 1.0 : 0.0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                centerTitle: true, // Center title when collapsed
                title: innerBoxIsScrolled 
                    ? Text(currentAccount.displayName ?? currentAccount.username, style: const TextStyle(fontSize: 18)) 
                    : null,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Optional: Original header image as a dimmed background
                    if (currentAccount.header != null && currentAccount.header!.isNotEmpty)
                      Image.network(
                        currentAccount.header!,
                        fit: BoxFit.cover,
                        // Optional: Dim or blur the header image if avatar is main focus
                        color: Colors.black.withOpacity(0.6), 
                        colorBlendMode: BlendMode.darken,
                      )
                    else
                      Container(color: colorScheme.surfaceContainerLowest), // Fallback background

                    // Centered Avatar
                    Center(
                      child: Container(
                        padding:  EdgeInsets.all(_headerAvatarBorderWidth).copyWith(top: _headerAvatarBorderWidth + 64),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor.withOpacity(0.85), // Semi-transparent border
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: CircleAvatar(
                          radius: _headerAvatarRadius,
                          backgroundImage: currentAccount.avatar != null && currentAccount.avatar!.isNotEmpty
                              ? NetworkImage(currentAccount.avatar!)
                              : null,
                          onBackgroundImageError: (_, __) {},
                          backgroundColor: colorScheme.surfaceVariant, // Fallback if image fails
                          child: (currentAccount.avatar == null || currentAccount.avatar!.isEmpty)
                              ? Text(
                                  currentAccount.displayName?.isNotEmpty == true
                                      ? currentAccount.displayName![0].toUpperCase()
                                      : currentAccount.username[0].toUpperCase(),
                                  style: TextStyle(fontSize: _headerAvatarRadius * 0.6, color: colorScheme.onSurfaceVariant),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share_outlined), tooltip: "Share Profile", onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert), tooltip: "More options", onPressed: () {}),
              ],
            ),
          ),
        ];
      },
      body: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for Display Name, @acct, and Follow Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentAccount.displayName ?? currentAccount.username,
                                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (currentAccount.acct != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      "@${currentAccount.acct}",
                                      style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16), // Space between text and button
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                            label: const Text("Follow"),
                            onPressed: () { /* TODO: Implement follow/unfollow */ },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0), // Space after name/acct/button block
                      
                      if (currentAccount.note != null && currentAccount.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: HtmlRenderer(html: currentAccount.note!, onMentionTapped: (acct) {
                            if (acct == currentAccount.acct || "@$acct" == currentAccount.acct) return;
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(acctIdentifier: acct)));
                          }),
                        ),
                      if (currentAccount.fields.isNotEmpty) ...[
                        _buildFields(context, currentAccount.fields),
                        const SizedBox(height: 12),
                      ],
                      _buildStatsRow(context, currentAccount),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 2.5,
                    tabs: const [Tab(text: "POSTS"), Tab(text: "REPLIES"), Tab(text: "MEDIA")],
                  ),
                ),
                pinned: true,
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    UserPostsFeed(accountId: currentAccount.id),
                    UserRepliesFeed(accountId: currentAccount.id),
                    UserMediaFeed(accountId: currentAccount.id),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  // _buildStatsRow, _buildStatItem, _buildFields, _SliverAppBarDelegate methods remain the same
  // ... (ensure these methods are copied from the previous correct version) ...
  Widget _buildStatsRow(BuildContext context, MastodonAccountModel account) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, "Posts", account.statusesCount),
            const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4),
            _buildStatItem(context, "Following", account.followingCount),
            const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4),
            _buildStatItem(context, "Followers", account.followersCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    final theme = Theme.of(context);
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: theme.colorScheme.onSurface,
        ),
        onPressed: () {
          print("$label tapped");
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(BuildContext context, List<MastodonFieldModel> fields) {
    if (fields.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.map((field) {
          bool isVerified = field.verifiedAt != null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    field.name,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: HtmlRenderer(
                    html: field.value,
                    onMentionTapped: (acct) {
                       if (acct == _account?.acct || "@$acct" == _account?.acct) return;
                       Navigator.of(context).push(MaterialPageRoute(
                         builder: (context) => ProfilePage(acctIdentifier: acct),
                       ));
                    },
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: "Verified on ${DateTime.tryParse(field.verifiedAt ?? '')?.toLocal().toString().substring(0,10) ?? 'N/A'}",
                    child: Icon(Icons.verified_user_rounded, color: Colors.green.shade500, size: 18),
                  )
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, 
      child: Material(elevation: shrinkOffset > 0 ? 1.0 : 0.0, color: Theme.of(context).colorScheme.surface, child: _tabBar));
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => _tabBar != oldDelegate._tabBar;
}

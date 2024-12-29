import 'package:fedi_pipe/components/timeline_feed.dart';
import 'package:fedi_pipe/pages/compose_page.dart';
import 'package:fedi_pipe/pages/drafts_page.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTimelinePage extends StatefulWidget {
  const HomeTimelinePage({Key? key}) : super(key: key);

  @override
  State<HomeTimelinePage> createState() => _HomeTimelinePageState();
}

class _HomeTimelinePageState extends State<HomeTimelinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Timeline'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ComposePage()),
            );
          },
          child: const Icon(Icons.add),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: const Text('Fedi Pipe'),
                decoration: BoxDecoration(),
              ),
              ListTile(
                title: const Text('Public Timeline'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Local Timeline'),
                onTap: () {
                  Navigator.of(context).pushNamed('/local');
                },
              ),
              ListTile(
                title: const Text('Federated Timeline'),
                onTap: () {
                  Navigator.of(context).pushNamed('/federated');
                },
              ),
              ListTile(
                title: const Text('Manage Accounts'),
                onTap: () {
                  context.pushNamed('manage-accounts');
                },
              ),
              ListTile(
                title: const Text('drafts'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DraftsPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: TimelineFeed(feedType: FeedType.home));
  }
}

import 'package:fedi_pipe/pages/compose_page.dart';
import 'package:fedi_pipe/pages/drafts_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;

  const DefaultLayout({
    Key? key,
    required this.body,
    required this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        centerTitle: true,
        leading: leading ??
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            }),
        actions: actions,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ComposePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: body,
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
    );
  }
}

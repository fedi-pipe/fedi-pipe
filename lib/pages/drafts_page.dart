import 'package:fedi_pipe/repositories/persistent/drafts_repository.dart';
import 'package:flutter/material.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({
    super.key,
  });

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafts'),
      ),
      body: FutureBuilder(
        future: DraftsRepository().getDrafts(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final drafts = snapshot.data!;

          return ListView.builder(
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts.elementAt(index);

              return ListTile(
                title: Text((draft ?? {})['content']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    DraftsRepository().deleteDraft(draft['id']);
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

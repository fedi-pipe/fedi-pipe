import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';

class ComposePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ComposePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What\'s happening?',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Post the status
                print(_controller.text);
                MastodonStatusRepository.postStatus(_controller.text);

                Navigator.of(context).pop();
                // Add a snackbar to show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Posted!'),
                  ),
                );
              },
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:fedi_pipe/repositories/persistent/drafts_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertagger/fluttertagger.dart';

class ComposePage extends StatefulWidget {
  ComposePage({
    super.key,
  });

  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  List<MastodonAccountModel> accounts = [];
  final FlutterTaggerController flutterTaggerController = FlutterTaggerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlutterTagger(
                controller: flutterTaggerController,
                searchRegex: RegExp(r'[a-zA-Z0-9_@#]+'),
                onSearch: (query, triggerCharacter) {
                  if (triggerCharacter == '@') {
                    MastodonAccountRepository.searchAccounts(query).then((value) {
                      setState(() {
                        accounts = value;
                      });
                    });
                  }
                },
                triggerCharacterAndStyles: const {
                  '@': TextStyle(color: Colors.pinkAccent),
                  '#': TextStyle(color: Colors.blueAccent),
                },
                overlayPosition: OverlayPosition.bottom,
                overlayHeight: 10,
                overlay: Container(),
                builder: (context, textFieldKey) {
                  return TextField(
                    key: textFieldKey,
                    controller: flutterTaggerController,
                    minLines: 5,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'What\'s happening?',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ),
            Stack(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Post the status
                          print(flutterTaggerController.text);
                          MastodonStatusRepository.postStatus(flutterTaggerController.text);

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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final repository = DraftsRepository();
                          repository.createDraft(flutterTaggerController.text);
                        },
                        child: Text('Save as draft'),
                      ),
                    ),
                  ],
                ),
                if (accounts.isNotEmpty)
                  SearchResultView(
                    accounts: accounts,
                    onTap: (account) {
                      flutterTaggerController.addTag(id: account.id, name: '${account.acct}');
                      setState(() {
                        accounts = [];
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return ListTile(
            title: Text('@${account.acct}'),
            onTap: () => onTap(account),
          );
        },
      ),
    );
  }
}

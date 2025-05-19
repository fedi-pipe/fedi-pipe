// lib/components/shared_compose_widget.dart
import 'package:fedi_pipe/components/search_result_view.dart'; // Ensure this path is correct
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/repositories/mastodon/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertagger/fluttertagger.dart';

class SharedComposeWidget extends StatefulWidget {
  final FlutterTaggerController taggerController;
  final String hintText;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;
  final Function(String)? onTextChanged;

  const SharedComposeWidget({
    super.key,
    required this.taggerController,
    required this.hintText,
    this.minLines = 5, // Default value
    this.maxLines = 8, // Default value, can be adjusted
    this.focusNode,
    this.onTextChanged,
  });

  @override
  State<SharedComposeWidget> createState() => _SharedComposeWidgetState();
}

class _SharedComposeWidgetState extends State<SharedComposeWidget> {
  List<MastodonAccountModel> _accounts = [];
  String _currentQuery = "";
  String _currentTrigger = "";

  @override
  void initState() {
    super.initState();
    widget.taggerController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.taggerController.removeListener(_handleTextChanged);
    // Note: The TaggerController itself is managed by the parent widget that creates it.
    super.dispose();
  }

  void _handleTextChanged() {
    widget.onTextChanged?.call(widget.taggerController.text);
  }

  Future<void> _searchAccounts(String query) async {
    if (query.isEmpty && _currentTrigger == '@') {
      if (mounted) {
        setState(() {
          _accounts = [];
        });
      }
      return;
    }
    // Only search if the query is non-empty for mentions
    if (query.isNotEmpty && _currentTrigger == '@') {
      final results = await MastodonAccountRepository.searchAccounts(query);
      if (mounted) {
        setState(() {
          _accounts = results;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _accounts = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterTagger(
      controller: widget.taggerController,
      searchRegex: RegExp(r'[a-zA-Z0-9_@#]+'), // Regex to detect words, @mentions, #hashtags
      onSearch: (query, triggerCharacter) {
        _currentQuery = query;
        _currentTrigger = triggerCharacter;
        if (triggerCharacter == '@') {
          _searchAccounts(query);
        } else if (triggerCharacter == '#') {
          // Placeholder for hashtag search if you implement it
          // For now, clear account suggestions if a hashtag is being typed
          if (mounted) {
            setState(() {
              _accounts = [];
            });
          }
        } else {
          // Clear suggestions if no specific trigger or an invalid one
          if (mounted) {
            setState(() {
              _accounts = [];
            });
          }
        }
      },
      triggerCharacterAndStyles: const {
        '@': TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold), // Style for @mentions
        '#': TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold), // Style for #hashtags
      },
      overlayPosition: OverlayPosition.bottom, // Display suggestions below the text field
      overlay: (_accounts.isNotEmpty && _currentTrigger == '@') // Only show overlay for @mentions with results
          ? SearchResultView(
              accounts: _accounts,
              onTap: (account) {
                // account.acct is preferred as it can contain the domain for remote users
                widget.taggerController.addTag(id: account.id, name: account.acct ?? account.username);
                if (mounted) {
                  setState(() {
                    _accounts = []; // Hide overlay after selection
                    _currentQuery = "";
                    _currentTrigger = "";
                  });
                }
              },
            )
          : const SizedBox.shrink(), // Show nothing if no accounts to suggest or not an @ trigger
      builder: (context, textFieldKey) {
        return TextField(
          key: textFieldKey, // Important for FlutterTagger to manage the TextField
          focusNode: widget.focusNode,
          controller: widget.taggerController,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textCapitalization: TextCapitalization.sentences, // Good for general text input
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            filled: true, // Add a subtle background color
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
          ),
        );
      },
    );
  }
}

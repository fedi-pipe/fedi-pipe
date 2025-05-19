// lib/components/shared_compose_widget.dart
import 'package:fedi_pipe/components/search_result_view.dart';
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
    this.minLines = 5,
    this.maxLines = 8,
    this.focusNode,
    this.onTextChanged,
  });

  @override
  State<SharedComposeWidget> createState() => _SharedComposeWidgetState();
}

class _SharedComposeWidgetState extends State<SharedComposeWidget> {
  final GlobalKey _textFieldContainerKey = GlobalKey(); // To get TextField's approximate position
  List<MastodonAccountModel> _accounts = [];
  String _currentQuery = "";
  String _currentTrigger = "";
  OverlayPosition _currentOverlayPosition = OverlayPosition.bottom;

  // Constants for estimating overlay height, mirroring SearchResultView's preferences
  static const double _overlayItemHeight = 58.0;
  static const int _overlayMaxVisibleItems = 4;
  static const double _preferredOverlayHeight = _overlayMaxVisibleItems * _overlayItemHeight;

  @override
  void initState() {
    super.initState();
    widget.taggerController.addListener(_onTextOrFocusChange);
    widget.focusNode?.addListener(_onTextOrFocusChange);

    // Initial position calculation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndSetOverlayPosition();
    });
  }

  @override
  void dispose() {
    widget.taggerController.removeListener(_onTextOrFocusChange);
    widget.focusNode?.removeListener(_onTextOrFocusChange);
    super.dispose();
  }

  void _onTextOrFocusChange() {
    // Recalculate position when text changes (might change TextField height/cursor pos)
    // or when focus changes (keyboard might appear/disappear).
    // Use a post-frame callback to ensure layout is stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onTextChanged?.call(widget.taggerController.text);
        _calculateAndSetOverlayPosition();
      }
    });
  }

  void _calculateAndSetOverlayPosition() {
    if (!mounted || _textFieldContainerKey.currentContext == null) {
      // Attempt to default to bottom if context isn't ready,
      // but avoid calling setState if it's already bottom or during build.
      if (_currentOverlayPosition != OverlayPosition.bottom && mounted) {
        // Check if a setState is truly needed and safe here.
        // setState(() { _currentOverlayPosition = OverlayPosition.bottom; });
      }
      return;
    }

    final BuildContext textFieldContext = _textFieldContainerKey.currentContext!;
    final RenderBox? renderBox = textFieldContext.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) return;

    final textFieldSize = renderBox.size;
    final textFieldTopLeftGlobal = renderBox.localToGlobal(Offset.zero);
    final textFieldBottomYGlobal = textFieldTopLeftGlobal.dy + textFieldSize.height;
    final textFieldTopYGlobal = textFieldTopLeftGlobal.dy;

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final statusBarHeight = mediaQuery.padding.top;

    final spaceBelow = screenHeight - textFieldBottomYGlobal - keyboardHeight;
    final spaceAbove = textFieldTopYGlobal - statusBarHeight;

    OverlayPosition newPosition = OverlayPosition.bottom; // Default

    // Heuristic: "If space below is under half of overlay height, try to place it on top"
    if (spaceBelow < (_preferredOverlayHeight / 1.5)) {
      if (spaceAbove >= _preferredOverlayHeight) {
        newPosition = OverlayPosition.top;
      } else if (spaceAbove > spaceBelow && spaceAbove > _overlayItemHeight * 1.5) {
        // If not enough for full above, but 'above' has more space and can fit ~1.5 items
        newPosition = OverlayPosition.top;
      }
    }

    if (_currentOverlayPosition != newPosition) {
      setState(() {
        _currentOverlayPosition = newPosition;
      });
    }
  }

  Future<void> _searchAccounts(String query) async {
    if (query.isEmpty && _currentTrigger == '@') {
      if (mounted) {
        setState(() => _accounts = []);
        _calculateAndSetOverlayPosition(); // Recalculate as overlay might hide
      }
      return;
    }
    if (query.isNotEmpty && _currentTrigger == '@') {
      final results = await MastodonAccountRepository.searchAccounts(query);
      if (mounted) {
        setState(() => _accounts = results);
        // After accounts are updated (and overlay might show/change size), recalculate position
        WidgetsBinding.instance.addPostFrameCallback((_) => _calculateAndSetOverlayPosition());
      }
    } else {
      if (mounted) {
        setState(() => _accounts = []);
        _calculateAndSetOverlayPosition(); // Recalculate as overlay might hide
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call calculation here too, as build might be triggered by parent MediaQuery changes
    // But ensure it's done post-frame to avoid setState during build issues.
    // The listeners are generally preferred.
    // WidgetsBinding.instance.addPostFrameCallback((_) => _calculateAndSetOverlayPosition());

    return Container(
      // This container's key helps us find the reference position
      key: _textFieldContainerKey,
      child: FlutterTagger(
        controller: widget.taggerController,
        overlayPosition: _currentOverlayPosition, // Use the dynamic position
        searchRegex: RegExp(r'[a-zA-Z0-9_@#]+'),
        onSearch: (query, triggerCharacter) {
          _currentQuery = query;
          _currentTrigger = triggerCharacter;
          if (triggerCharacter == '@') {
            _searchAccounts(query);
          } else if (triggerCharacter == '#') {
            if (mounted) setState(() => _accounts = []);
            _calculateAndSetOverlayPosition();
          } else {
            if (mounted) setState(() => _accounts = []);
            _calculateAndSetOverlayPosition();
          }
        },
        triggerCharacterAndStyles: const {
          '@': TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
          '#': TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        },
        overlay: (_accounts.isNotEmpty && _currentTrigger == '@')
            ? SearchResultView(
                accounts: _accounts,
                onTap: (account) {
                  widget.taggerController.addTag(id: account.id, name: account.acct ?? account.username);
                  if (mounted) {
                    setState(() {
                      _accounts = [];
                      _currentQuery = "";
                      _currentTrigger = "";
                    });
                    // After tag is added, text changes, listener _onTextOrFocusChange will call _calculateAndSetOverlayPosition
                  }
                },
              )
            : const SizedBox.shrink(),
        builder: (context, textFieldKeyFromBuilder) {
          // textFieldKeyFromBuilder is for FlutterTagger's internal use.
          // Our _textFieldContainerKey on the wrapping Container is used for position measurement.
          return TextField(
            key: textFieldKeyFromBuilder,
            focusNode: widget.focusNode,
            controller: widget.taggerController,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
            ),
          );
        },
      ),
    );
  }
}


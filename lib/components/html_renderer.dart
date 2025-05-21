import 'package:fedi_pipe/extensions/string.dart';
import 'package:fedi_pipe/main.dart'; // For AppDarkPalette
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlRenderer extends StatelessWidget {
  final String html;
  final void Function(String acctIdentifier)? onMentionTapped;

  const HtmlRenderer({super.key, required this.html, this.onMentionTapped});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Helper function to convert Color to CSS hex string
    String colorToCssHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2)}';
    }

    return HtmlWidget(
      html.trim(),
      textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      // renderMode: RenderMode.column, // Or remove to use default. 'richText' is not a valid member.
                                      // Default often works well; 'column' can also be effective.
                                      // The key is often in CSS-like styling.
      customStylesBuilder: (element) {
        if (element.localName == 'p') {
          return {
            'margin-top': '0px',
            'margin-bottom': '0.2em', // Small bottom margin for paragraph separation if desired
            'padding-top': '0px',
            'padding-bottom': '0px',
          };
        }
        if (element.localName == 'a') {
          return {
            'display': 'inline', // Should be default for <a> but good to be explicit
            'margin': '0px',
            'padding': '0px',
            'text-decoration': 'none', // We'll handle decoration via TextSpan style
          };
        }
        if (element.localName == 'code') {
          return {
            'background-color': colorToCssHex(colorScheme.surfaceContainerLowest),
            'color': colorToCssHex(colorScheme.onSurfaceVariant),
            'font-family': 'monospace',
            'padding': '0.2em 0.4em',
            'border-radius': '4px',
            'font-size': '0.9em',
          };
        }
        if (element.localName == 'pre') {
          return {
            'background-color': colorToCssHex(colorScheme.surfaceContainerLowest),
            'color': colorToCssHex(colorScheme.onSurfaceVariant),
            'font-family': 'monospace',
            'padding': '1em',
            'margin-top': '0.5em',
            'margin-bottom': '0.5em',
            'border-radius': '4px',
            'overflow': 'auto',
            'white-space': 'pre-wrap', // Allow wrapping within pre block
          };
        }
        if (element.localName == 'ul' || element.localName == 'ol') {
          return {'margin-top': '0.2em', 'margin-bottom': '0.5em', 'padding-left': '1.5em'};
        }
        if (element.localName == 'li') {
          return {'margin-top': '0.1em', 'margin-bottom': '0.1em'};
        }
        return null;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'a') {
          final String href = element.attributes['href'] ?? '';
          final String textContent = element.text;

          final bool isMention = element.classes.contains('mention') ||
              (href.contains('@') && Uri.tryParse(href)?.pathSegments.isNotEmpty == true && (Uri.tryParse(href)!.pathSegments.first.startsWith('@') || Uri.tryParse(href)!.pathSegments.first == 'users')) ||
              (textContent.startsWith('@') && element.classes.contains('u-url'));

          final bool isHashtag = element.classes.contains('hashtag') || (href.contains('/tags/') && textContent.startsWith('#'));

          TextStyle linkStyle;
          GestureTapCallback? onTapCallback;

          if (isMention) {
            String mentionText = textContent;
            if (!mentionText.startsWith('@')) {
              mentionText = "@$mentionText";
            }

            String acctIdentifier = mentionText;
            try {
              final uri = Uri.parse(href);
              String usernameFromHref = uri.pathSegments.lastWhere((seg) => seg.isNotEmpty && !seg.startsWith('tags'), orElse: () => "");
              if (usernameFromHref.startsWith('@')) usernameFromHref = usernameFromHref.substring(1);

              if (usernameFromHref.isNotEmpty) {
                acctIdentifier = "@$usernameFromHref@${uri.host}";
              } else if (textContent.isNotEmpty && !textContent.contains("@")) {
                acctIdentifier = "@$textContent@${uri.host}";
              } else if (textContent.startsWith('@') && textContent.contains('@') && textContent.split('@').length == 3) {
                acctIdentifier = textContent;
              }
            } catch (_) { /* fallback to mentionText */ }
            
            linkStyle = TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            );
            if (onMentionTapped != null) {
              onTapCallback = () => onMentionTapped!(acctIdentifier);
            }
          } else if (isHashtag) {
            String hashtagText = textContent;
            if (!hashtagText.startsWith('#')) {
              hashtagText = "#$hashtagText";
            }
            linkStyle = TextStyle(
              color: AppDarkPalette.hashtagColor, // Using the specific hashtag color
              fontWeight: FontWeight.normal,
            );
            if (href.isNotEmpty) {
              onTapCallback = () async {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              };
            }
          } else {
            // General links
            linkStyle = TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: colorScheme.primary.withOpacity(0.7),
            );
            if (href.isNotEmpty) {
              onTapCallback = () async {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              };
            }
          }

          // Use InlineCustomWidget with Text.rich for TextSpans with recognizers
          return InlineCustomWidget(
            child: Text.rich(
              TextSpan(
                text: isHashtag ? (textContent.startsWith('#') ? textContent : "#$textContent") : textContent,
                style: linkStyle,
                recognizer: onTapCallback != null ? (TapGestureRecognizer()..onTap = onTapCallback) : null,
              ),
            ),
          );
        }
        return null;
      },
      onTapUrl: (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      },
    );
  }

  String sanitizedHyperlinkContent(String content) {
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return readableClampedUrl(content);
    }
    return content.trim();
  }

  String readableClampedUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String path = uri.path;
      if (path == '/' || path.isEmpty) {
        return uri.host;
      }
      return "${uri.host}${path.clamp(20)}";
    } catch (e) {
      return url.clamp(30);
    }
  }
}

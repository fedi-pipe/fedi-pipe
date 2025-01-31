import 'package:fedi_pipe/components/mastodon_profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlRenderer extends StatelessWidget {
  final String html;
  const HtmlRenderer({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      customStylesBuilder: (element) {
        if (element.localName == 'code') {
          return {
            'color': 'green',
            'font-size': 'medium',
            'margin-left': '2em',
          };
        }
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'a') {
          if ((element.attributes['class'] ?? '').contains('mention')) {
            final href = element.attributes['href'];
            final text = element.text;

            final urlHost = Uri.parse(href!).host;
            final acct = "${text}@${urlHost}";

            return GestureDetector(
              onTap: () {
                print("------");
                print(acct);
                print("------");
                showMastodonProfileBottomSheetWithLoading(context, acct);
              },
              child: Text(element.text,
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
            );
          }

          return InlineCustomWidget(
            child: GestureDetector(
              onTap: () async {
                final url = element.attributes['href'];
                final uri = Uri.parse(url!);
                launchUrl(uri);
              },
              child: Text(element.text,
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
            ),
          );
        }
      },
    );
  }
}

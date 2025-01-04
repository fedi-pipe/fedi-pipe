import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class HtmlRenderer extends StatelessWidget {
  final String html;
  const HtmlRenderer({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(html);
  }
}

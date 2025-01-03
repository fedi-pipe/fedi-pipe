import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DomNodeRenderer {
  final DOMNode node;

  DomNodeRenderer({required this.node});

  InlineSpan render() {
    if (node is TextNode) {
      return TextSpan(text: (node as TextNode).text, style: TextStyle(overflow: TextOverflow.visible));
    }

    if (node is ElementNode) {
      List<InlineSpan> children;
      final elementNode = node as ElementNode;
      children = elementNode.children.map((e) => DomNodeRenderer(node: e).render()).toList();
      return wrapElement(elementNode, children);
    }

    return WidgetSpan(child: Container());
  }

  List<dynamic> _printTextNodes(List<DOMNode> elementNode) {
    final texts = elementNode.map((e) {
      if (e is TextNode) {
        return (e as TextNode).text;
      }

      if (e is ElementNode) {
        return _printTextNodes((e as ElementNode).children);
      }

      return "";
    }).toList();
    return texts;
  }

  InlineSpan wrapElement(ElementNode elementNode, List<InlineSpan> children) {
    final style = styledElement(elementNode, children);

    // line break
    if (elementNode.tag == "br") {
      return TextSpan(text: "\n", style: TextStyle(overflow: TextOverflow.visible));
    }

    //print([
    //  elementNode.tag,
    //  elementNode.attributes,
    //  _printTextNodes(elementNode.children),
    //]);

    // block elements
    if (blockElements.contains(elementNode.tag)) {
      return WidgetSpan(
        child: Container(
          child: Text.rich(TextSpan(children: [
            TextSpan(
              text: "\n",
              style: TextStyle(fontSize: 0, overflow: TextOverflow.visible),
            ),
            ...children
          ])),
        ),
      );
    }

    return style;
  }

  InlineSpan styledElement(ElementNode elementNode, List<InlineSpan> children) {
    switch (elementNode.tag) {
      // TODO: We need to inspect why this tag is not including text node
      case "a":
        String href = '';
        if (elementNode.attributes!.containsKey('href')) href = elementNode.attributes!['href']!;
        return WidgetSpan(
            child: GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(href));
                },
                child: Text.rich(TextSpan(
                  text: href,
                  style: TextStyle(color: Colors.blue, overflow: TextOverflow.visible),
                ))));
      case "p":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 16, overflow: TextOverflow.visible),
        );
      case "h1":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 32, overflow: TextOverflow.visible),
        );
      case "h2":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 24, overflow: TextOverflow.visible),
        );
      case "h3":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 20, overflow: TextOverflow.visible),
        );
      case "h4":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 18, overflow: TextOverflow.visible),
        );
      case "h5":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 16, overflow: TextOverflow.visible),
        );
      case "h6":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 14, overflow: TextOverflow.visible),
        );
      case "b":
        return TextSpan(
          children: children,
          style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.visible),
        );
      case "i":
        return TextSpan(
          children: children,
          style: TextStyle(fontStyle: FontStyle.italic, overflow: TextOverflow.visible),
        );
      case "u":
        return TextSpan(
          children: children,
          style: TextStyle(decoration: TextDecoration.underline, overflow: TextOverflow.visible),
        );
      case "s":
        return TextSpan(
          children: children,
          style: TextStyle(decoration: TextDecoration.lineThrough, overflow: TextOverflow.visible),
        );
      case "fragment":
        return TextSpan(children: children);
      default:
        return TextSpan(children: children);
    }
  }
}

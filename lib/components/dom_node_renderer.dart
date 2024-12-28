import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DomNodeRenderer {
  final DOMNode node;

  DomNodeRenderer({required this.node});

  InlineSpan render() {
    if (node is TextNode) {
      return TextSpan(text: (node as TextNode).text);
    }

    if (node is ElementNode) {
      List<InlineSpan> children;
      final elementNode = node as ElementNode;
      children = elementNode.children.map((e) => DomNodeRenderer(node: e).render()).toList();
      return wrapElement(elementNode, children);
    }

    return WidgetSpan(child: Container());
  }

  InlineSpan wrapElement(ElementNode elementNode, List<InlineSpan> children) {
    final style = styledElement(elementNode, children);

    // line break
    if (elementNode.tag == "br") {
      return TextSpan(text: "\n");
    }

    // block elements
    if (blockElements.contains(elementNode.tag)) {
      return WidgetSpan(
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text.rich(TextSpan(children: children))],
          ),
        ),
      );
    }

    return style;
  }

  InlineSpan styledElement(ElementNode elementNode, List<InlineSpan> children) {
    switch (elementNode.tag) {
      case "a":
        return TextSpan(
          children: children,
          style: TextStyle(color: Colors.blue),
        );
      case "p":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 16),
        );
      case "h1":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 32),
        );
      case "h2":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 24),
        );
      case "h3":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 20),
        );
      case "h4":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 18),
        );
      case "h5":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 16),
        );
      case "h6":
        return TextSpan(
          children: children,
          style: TextStyle(fontSize: 14),
        );
      case "b":
        return TextSpan(
          children: children,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case "i":
        return TextSpan(
          children: children,
          style: TextStyle(fontStyle: FontStyle.italic),
        );
      case "u":
        return TextSpan(
          children: children,
          style: TextStyle(decoration: TextDecoration.underline),
        );
      case "s":
        return TextSpan(
          children: children,
          style: TextStyle(decoration: TextDecoration.lineThrough),
        );
      case "fragment":
        return TextSpan(children: children);
      default:
        return TextSpan(children: children);
    }
  }
}

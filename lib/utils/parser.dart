import 'dart:async';
import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

const selfClosingTags = [
  "area",
  "base",
  "br",
  "col",
  "embed",
  "hr",
  "img",
  "input",
  "link",
  "meta",
  "param",
  "source",
  "track",
  "wbr",
];

const blockElements = [
  "html",
  "body",
  "article",
  "section",
  "nav",
  "aside",
  "h1",
  "h2",
  "h3",
  "4",
  "h5",
  "h6",
  "hgroup",
  "header",
  "footer",
  "address",
  "p",
  "hr",
  "pre",
  "blockquote",
  "ol",
  "ul",
  "menu",
  "li",
  "dl",
  "dt",
  "dd",
  "figure",
  "figcaption",
  "main",
  "div",
  "table",
  "form",
  "fieldset",
  "legend",
  "details",
  "summary",
];

abstract class DOMNode {
  // o.text = text
  // o.parent = parent`
  // o.children = children
  DOMNode? parent;
  List<DOMNode> children;
  LinkedHashMap<Object, String>? attributes;

  DOMNode({this.parent, this.children = const [], this.attributes});

  List<DOMNode> flatten() {
    final nodes = <DOMNode>[];
    nodes.add(this);

    for (final child in children) {
      nodes.addAll(child.flatten());
    }

    return nodes;
  }
}

class TextNode extends DOMNode {
  String text;

  TextNode(this.text, {super.parent, super.children});
}

class ElementNode extends DOMNode {
  String tag;

  ElementNode(this.tag, {super.attributes, super.parent, super.children});
}

class HTMLParser {
  static int index = 0;
  late String content;
  List<String> unfinishedTags = [];

  HTMLParser(String html) {
    content = "<html>$html</html>";
  }

  Stream<String> generateContentStream(String content) async* {
    for (int i = 0; i < content.length; i++) {
      yield content[i];
    }
  }

  Future<DOMNode> parse() async {
    HtmlParser parser = HtmlParser(content);
    final document = parser.parse();
    final bodyNode = document.querySelector("body");
    final rootNode = ElementNode("html");

    // TODO : assign children to parent recursively
    final children = bodyNode!.children.map((e) {
      return ElementNode(e.localName ?? "", children: []);
    });

    rootNode.children = children.toList();

    return rootNode;
  }
}

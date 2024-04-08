import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses opening tag from stream', () async {
    final parser = HTMLParser('<div></div>');

    final rootNode = await parser.parse() as ElementNode;
    expect(rootNode.tag, "body");
    expect((rootNode.children.first as ElementNode).tag, "div");
  });

  test("parses next node", () async {
    final parser = HTMLParser('<div>dddd<p>aaa</p>ddd</div>');

    final rootNode = await parser.parse() as ElementNode;
    final domNodes = rootNode.flatten();

    expect(domNodes.length, 6);
    expect((domNodes[0] as ElementNode).tag, "body");
    expect((domNodes[1] as ElementNode).tag, "div");
    expect((domNodes[2] as TextNode).text, "dddd");
    expect((domNodes[3] as ElementNode).tag, "p");
    expect((domNodes[4] as TextNode).text, "aaa");
    expect((domNodes[5] as TextNode).text, "ddd");
  });
}

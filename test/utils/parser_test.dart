import 'package:fedi_pipe/utils/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses opening tag from stream', () async {
    final parser = HTMLParser('<div></div>');

    final document = await parser.parse() as ElementNode;
    expect(document.tag, "html");
    expect((document.children.first as ElementNode).tag, "div");
  });
}

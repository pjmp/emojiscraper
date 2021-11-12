import 'package:emojiscraper/emojiscraper.dart' as emojiscraper;
import 'package:test/test.dart' as test;

void main() {
  test.test('parseTextToJson', () {
    test.inExclusiveRange(emojiscraper.parseTextToJson('').length, 0);
  });
}

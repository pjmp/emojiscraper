import 'package:emojiscraper/emojiscraper.dart' as emojiscraper;
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(emojiscraper.fetchVersions(), 42);
  });
}

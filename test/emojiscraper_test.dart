import 'package:emojiscraper/scraper.dart' as emojiscraper;
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(emojiscraper.fetchVersions(), 42);
  });
}

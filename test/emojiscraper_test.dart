import 'dart:convert';

import 'package:emojiscraper/emojiscraper.dart';
import 'package:test/test.dart';

void main() {
  test('calling parseTextToJson :: invalid input', () {
    expect(parseTextToJson(''), '[]');
  });

  test('parseTextToJson :: valid input', () {
    final encoder = JsonEncoder.withIndent('  ');

    final raw =
        '1FAF5 1F3FD   ; RGI_Emoji_Modifier_Sequence  ; index pointing at the viewer: medium skin tone                 # E14.0  [1] (🫵🏽)';
    expect(
        parseTextToJson(raw),
        encoder.convert([
          {
            'description': 'index pointing at the viewer: medium skin tone',
            'emoji': ['🫵🏽']
          }
        ]));
  });
}

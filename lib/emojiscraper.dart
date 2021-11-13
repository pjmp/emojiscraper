import 'dart:convert' show JsonEncoder, LineSplitter, utf8;
import 'dart:io' show HttpClient, HttpClientRequest, Platform, exit;

import 'package:html/dom.dart' show Document;

final String _baseUrl = Platform.environment['UNICODE_ORG_URL'] ??
    'https://unicode.org/Public/emoji';

/// Scrape https://unicode.org/Public/emoji, for available version.
Future<List<String>> fetchAvailableVersions() async {
  final request = await client(url: _baseUrl);

  final response = await request.close();

  final responseHtml = (await response.transform(utf8.decoder).toList()).join();

  final table = Document.html(responseHtml).querySelectorAll('tbody');

  final versions = table.fold<List<String>>([], (acc, row) {
    final column = row.querySelectorAll('td:nth-child(1)');

    column.skip(1).forEach((item) {
      final version = item.text.replaceFirst('/', '');

      acc.add(version);
    });

    return acc;
  });

  // sort the list in descending order
  versions.sort((a, b) => double.parse(a) > double.parse(b) ? 0 : 1);

  return versions;
}

/// Generic [HttpClientRequest] that does GET request.
Future<HttpClientRequest> client({required String url}) async {
  final client = HttpClient();

  final request = await client.getUrl(Uri.parse(url));

  return request;
}

/// Fetch emoji data.
/// Note: This will [exit] with message printed to stdout if status is not 200
Future<String> fetchEmojiData(String version) async {
  String url;

  // v1.0 doesn't have the file `emoji-sequences.txt` in server
  if (version == '1.0') {
    url = '$_baseUrl/$version/emoji-data.txt';
  } else {
    url = '$_baseUrl/$version/emoji-sequences.txt';
  }

  final request = await client(url: url);

  final response = await request.close();

  if (response.statusCode != 200) {
    print('error: ${response.statusCode} ${response.reasonPhrase}');
    exit(response.statusCode);
  }

  final contents = (await response.transform(utf8.decoder).toList()).join();

  return contents;
}

/// Takes raw string and formats it to json.
/// If you decode the result of the string returned by this then, the resulting object is represented as:
///```dart
/// // if only dart had union types or tuples
/// typedef Json = List<Map<String, Object>>;
///
/// Json json = {
///   'description': 'flag: Nepal',
///    'emoji': ['🇳🇵']
/// }
/// ```
String parseTextToJson(String text) {
  final lines = LineSplitter().convert(text);

  List<Map<String, Object>> emojis = [];

  for (final line in lines) {
    if (!line.startsWith(RegExp(r'[0-9]'))) {
      continue;
    }

    final reg = RegExp(r'\(.*?\)');

    final item = line.split(reg);

    if (item.length != 2) {
      continue;
    }

    final emoji = line
        .splitMapJoin((reg), onMatch: (m) => '${m[0]}', onNonMatch: (n) => '')
        .replaceAll(RegExp(r'\(|\)'), '')
        .split('..');

    String description;

    final head = item.first;
    final tail = item.last;

    if (tail.isEmpty) {
      description = head.split(';')[2].split('#')[0].trim();
    } else {
      description = tail.trim();
    }

    emojis.add({'description': description, 'emoji': emoji});
  }

  final encoder = JsonEncoder.withIndent('  ');

  return encoder.convert(emojis);
}

import 'dart:convert' show utf8;
import 'dart:io' show HttpClient, HttpClientRequest, Platform, exit;

import 'package:html/dom.dart' show Document;

final String _baseUrl = Platform.environment['UNICODE_ORG_URL'] ??
    'https://unicode.org/Public/emoji';

Future<List<String>> fetchVersions() async {
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

  return versions;
}

Future<HttpClientRequest> client({required String url}) async {
  final client = HttpClient();

  final request = await client.getUrl(Uri.parse(url));

  return request;
}

Future<String> downloadEmojiData(String version) async {
  final request = await client(url: '$_baseUrl/$version/emoji-sequences.txt');

  final response = await request.close();

  if (response.statusCode != 200) {
    print('error: ${response.statusCode} ${response.reasonPhrase}');
    exit(response.statusCode);
  }

  final contents = (await response.transform(utf8.decoder).toList()).join();

  return contents;
}

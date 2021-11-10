import 'dart:io' show exit, File;

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:emojiscraper/scraper.dart' as scraper;
import 'package:interact/interact.dart' show Select;
import 'package:yaml/yaml.dart' show loadYaml;

dynamic _packageInfo;
String? _packageName;
String? _packageVersion;
String? _packageDescription;

class CliOptions {
  static const options = [
    {'name': 'help', 'help': 'Print this help message.', 'flag': true},
    {
      'name': 'interactive',
      'help':
          'Interactively choose version from the list of available versions, else latest version is selected.',
      'flag': true
    },
    {'name': 'version', 'help': 'Print version information.', 'flag': true},
    {'name': 'list', 'help': 'List available emoji versions.', 'flag': true},
    {
      'name': 'edition',
      'help':
          'Choose version of emoji, i.e 14.0, 13.1 etc.\nNote: if version is not valid, it will exit with code `response.statusCode``.',
      'option': true
    },
    {
      'name': 'format',
      'help': 'Choose the format to dump to stdout or save to path.',
      'option': true,
      // 'defaultsTo': 'json',
      'allowed': {
        'raw': 'Data is not processed and left as it was downloaded.',
        'json': 'Data is parsed as JSON.',
      }
    },
    {
      'name': 'writeTo',
      'help': 'Write to path or stdout.',
      'option': true,
      // 'defaultsTo': 'stdout',
      'allowed': {
        'path': 'Write to path.',
        'stdout': 'Write to stdout.',
      }
    }
  ];

  late ArgParser parser;
  late ArgResults cli;

  CliOptions() {
    parser = ArgParser();
  }

  CliOptions generate() {
    for (final option in options) {
      if (option['flag'] != null || option['option'] != null) {
        final name = option['name'].toString();
        final abbr = name[0];
        final help = option['help'].toString();

        if (option['flag'] != null) {
          parser.addFlag(name, abbr: abbr, help: help, negatable: false);
        } else if (option['option'] != null) {
          final allowed = option['allowed'] != null
              ? (option['allowed'] as Map<String, String>)
              : null;

          parser.addOption(
            name,
            abbr: abbr,
            help: help,
            allowed: allowed?.keys.toList(),
            allowedHelp: allowed,
            defaultsTo: option['defaultsTo']?.toString(),
            valueHelp: name.toUpperCase(),
            // anything more to add?
          );
        }
      }
    }

    return this;
  }

  CliOptions run(List<String> arguments) {
    cli = parser.parse(arguments);
    return this;
  }

  bool validFlagsOrOptionsPassed() {
    return options.any((option) => cli.wasParsed(option['name']!.toString()));
  }
}

run(List<String> arguments) async {
  _packageInfo ??= loadYaml(File('pubspec.yaml').readAsStringSync());
  _packageName ??= _packageInfo['name'];
  _packageVersion ??= _packageInfo['version'];
  _packageDescription ??= _packageInfo['description'];

  final usage = '''USAGE:
  $_packageName --format=raw --writeTo=path
  $_packageName -fraw -wpath''';

  try {
    final app = CliOptions()
      ..generate()
      ..run(arguments);

    final cli = app.cli;

    if (app.validFlagsOrOptionsPassed()) {
      // show help
      if (cli['help']) {
        print('''
$_packageName $_packageVersion
$_packageDescription

$usage

OPTIONS:
${app.parser.usage}''');
        exit(0);
      }

      // show version
      if (cli['version']) {
        print('v$_packageVersion');
        exit(0);
      }

      // list versions
      if (cli['list']) {
        final versions = await scraper.fetchVersions();

        print('Available versions are:\n  ${versions.join('\n  ')}');
        exit(0);
      }

      // dump to stdout
      print(
          'format: ${cli['format']}\nwriteTo: ${cli['writeTo']}\nedition: ${cli['edition']}');

      var edition = cli['edition'],
          format = cli['format'],
          writeTo = cli['writeTo'],
          interactive = cli['interactive'];

      if (edition == null) {
        final versions = await scraper.fetchVersions();

        versions.sort((a, b) => double.parse(a) > double.parse(b) ? 0 : 1);

        if (interactive != null && interactive == true) {
          final selection = Select(
            prompt: 'Select version of emoji',
            options: versions,
          ).interact();

          edition = versions[selection];
        } else {
          edition = versions.first;
        }
      }

      final data = await scraper.downloadEmojiData(edition);

      if (writeTo == 'stdout') {
        if (format == 'raw') {
          print(data);
        } else if (format == 'json') {
          print('Parse & print');
        }
      } else if (writeTo == 'path') {
        if (format == 'raw') {
          print('Save as txt.');
        } else if (format == 'json') {
          print('Parse & save as json');
        }
      }

      if (format == null) {}
    } else {
      print('''
error: --format=<FORMAT> --writeTo=<PATH> is required

$usage

For more information try --help''');
      exit(1);
    }
  } catch (e) {
    print('''
${e.toString().replaceAll(RegExp(r'^(.*?Exception):'), 'error:')}

$usage''');
    exit(1);
  }
}

void dump(fmt) async {
  switch (fmt) {
    case 'raw':
      final versions = await scraper.fetchVersions();

      print(versions);

      break;
    case 'json':
      print('json mode');
      break;
    default:
      throw 'foo bar';
  }
}

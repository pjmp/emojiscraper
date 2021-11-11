import 'dart:io' show exit, File;

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:emojiscraper/emojiscraper.dart' as scraper;
import 'package:interact/interact.dart' show Select, Spinner;

import './app_info.dart' as app_info;

const _options = [
  {'name': 'help', 'help': 'Print this help message.', 'flag': true},
  {
    'name': 'interactive',
    'help': '''Interactively choose version from the list of available versions.
Note: if `--edition` is passed, this flag will be ignored.''',
    'flag': true
  },
  {'name': 'version', 'help': 'Print version information.', 'flag': true},
  {'name': 'list', 'help': 'List available emoji versions.', 'flag': true},
  {
    'name': 'edition',
    'help': '''Choose version of emoji, i.e 14.0, 13.1 etc.
Note: if version is not valid, it will exit with code `response.statusCode`.
      ''',
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

ArgParser _generate(ArgParser parser) {
  for (final option in _options) {
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

  return parser;
}

_validFlagsOrOptionsPassed(ArgResults cli) {
  return _options.any((option) => cli.wasParsed(option['name'].toString()));
}

String _usage() {
  final usage = '''USAGE:
  ${app_info.packageName} --format=raw --writeTo=path
  ${app_info.packageName} -fraw -wpath''';

  return usage;
}

String _help(String appUsage) {
  final help = '''
${app_info.packageName} ${app_info.packageVersion}
${app_info.packageDescription}

${_usage()}

OPTIONS:
$appUsage''';

  return help;
}

void _printNoArgsHelp() {
  print('''
error: --format=<FORMAT> --writeTo=<WRITETO> is required

${_usage()}

For more information try --help''');
}

/// catch all for any errors
void _printAllErrors(Object e) {
  print('''
${e.toString().replaceAll(RegExp(r'^(.*?Exception):'), 'error:')}

${_usage()}''');
}

run({required List<String> args}) async {
  try {
    final app = _generate(ArgParser());

    final cli = app.parse(args);

    if (_validFlagsOrOptionsPassed(cli)) {
      // show help
      if (cli['help']) {
        print(_help(app.usage));
        exit(0);
      }

      // show version
      if (cli['version']) {
        print(
            '${app_info.packageName} ${app_info.packageVersion} (${app_info.packageGitHash})');
        exit(0);
      }

      // list versions
      if (cli['list']) {
        final spin = Spinner(
          icon: '',
          rightPrompt: (done) => done ? '' : 'Fetching available versions',
        ).interact();

        final versions = await scraper.fetchVersions();

        spin.done();

        print('Available versions are:\n  ${versions.join('\n  ')}');
        exit(0);
      }

      var edition = cli['edition'],
          format = cli['format'],
          writeTo = cli['writeTo'],
          interactive = cli['interactive'];

      // if `--edition` is not passed
      if (edition == null) {
        // fetch available versions
        final versions = await scraper.fetchVersions();

        // sort the list in descending order
        versions.sort((a, b) => double.parse(a) > double.parse(b) ? 0 : 1);

        // if `--interactive` is passed
        if (interactive != null && interactive == true) {
          // prompt user to select from available versions
          final selection = Select(
            prompt: 'Select version of emoji',
            options: versions,
          ).interact();

          edition = versions[selection];
        } else {
          // just select latest available version if `--interactive` is not passed
          edition = versions.first;
        }
      }

      final data = await scraper.downloadEmojiData(edition);

      // dump to stdout
      if (writeTo == 'stdout') {
        if (format == 'raw') {
          print(data);
        } else if (format == 'json') {
          final json = scraper.parseTextToJson(data);
          print(json);
        }
      } else if (writeTo == 'path') {
        if (format == 'raw') {
          final file = await File('emoji-sequences.txt').create();
          await file.writeAsString(data);
        } else if (format == 'json') {
          final json = scraper.parseTextToJson(data);
          final file = await File('emoji-sequences.json').create();
          await file.writeAsString(json.toString());
        }
      } else {
        _printNoArgsHelp();
        exit(1);
      }
    } else {
      _printNoArgsHelp();
      exit(1);
    }
  } catch (e) {
    _printAllErrors(e);
    exit(1);
  }
}

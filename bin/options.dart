part of './cli.dart';

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
        // anything else to add?
      );
    }
  }

  return parser;
}

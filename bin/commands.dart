part of './cli.dart';

_validFlagsOrOptionsPassed(ArgResults cli) {
  return _options.any((option) => cli.wasParsed(option['name'].toString()));
}

String _usage() {
  final usage = '''USAGE:
  ${app_info.packageName} --format=raw --writeTo=path
  ${app_info.packageName} -fraw -wpath''';

  return usage;
}

Never _help(String appUsage) {
  final help = '''
${app_info.packageName} ${app_info.packageVersion}
${app_info.packageDescription}

${_usage()}

OPTIONS:
$appUsage''';

  print(help);

  exit(0);
}

Never _printNoArgsHelp() {
  print('''
error: --format=<FORMAT> --writeTo=<WRITETO> is required

${_usage()}

For more information try --help''');
  exit(1);
}

Never _version() {
  print('${app_info.packageName} ${app_info.packageVersion}');
  exit(0);
}

/// catch all for any errors
Never _printAllErrors(Object error) {
  print(error.toString().replaceAll(RegExp(r'^(.*?Exception):'), 'error:'));

  exit(1);
}

Never _invalidState() {
  print('Invalid option.\nRun `--help` to see all available options.');
  exit(1);
}

Future<Never> _printAvailableVersions() async {
  final spin = Spinner(
    icon: '',
    rightPrompt: (done) => done ? '' : 'Fetching available versions ...',
  ).interact();

  final versions = await scraper.fetchAvailableVersions();

  spin.done();

  print('Available versions are:\n  ${versions.join('\n  ')}');
  exit(0);
}

SpinnerState _spinner(String message) {
  return Spinner(
    icon: '',
    rightPrompt: (done) => done ? '' : message,
  ).interact();
}

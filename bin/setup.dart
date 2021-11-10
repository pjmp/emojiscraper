import 'dart:io' show File;

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart' show loadYaml;

final packageInfo = loadYaml(File('pubspec.yaml').readAsStringSync());
final packageName = packageInfo['name'];
final packageVersion = packageInfo['version'];
final packageDescription = packageInfo['description'];

final log = Logger(packageName);

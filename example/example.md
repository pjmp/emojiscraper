# Examples

## example.dart

```dart
import 'dart:io';

import 'package:emojiscraper/emojiscraper.dart';

Future<void> main(List<String> args) async {
    // fetch available versions
    final List<String> versions = await fetchAvailableVersions();

    // download emoji blobs
    final data = await fetchEmojiData(versions.first);
}

```
For additional examples see the [bin/cli.dart](../bin/cli.dart)
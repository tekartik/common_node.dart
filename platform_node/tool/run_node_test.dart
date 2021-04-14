import 'dart:async';

import 'package:process_run/shell_run.dart';

Future main() async {
  await run('dart --no-sound-null-safety test -p node -r expanded');
}

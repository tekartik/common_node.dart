import 'dart:async';

import 'package:process_run/shell_run.dart';

Future main() async {
  await run(
    'dart test -p node -r expanded -j 1 test/multiplatform/fs_memory_test.dart',
  );
}

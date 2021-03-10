import 'dart:async';

import 'package:process_run/shell_run.dart';

Future main() async {
  await run(
      'pub run test -p node -r expanded -j 1 test/node/fs_node_test.dart');
}

import 'dart:async';

import 'package:process_run/shell_run.dart';
import 'package:tekartik_fs_test/test_common.dart';

Future main() async {
  await run('dart test -p node -r expanded -j 1 test/node/fs_node_test.dart'
      //  ' ${devWarning('-N rename_with_content')}'
      // ' ${devWarning('-N write_on_directory')}'
      //
      );
}

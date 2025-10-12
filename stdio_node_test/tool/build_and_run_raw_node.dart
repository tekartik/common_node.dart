import 'dart:io';

import 'package:tekartik_app_node_build/app_build.dart';

Future main() async {
  var builder = NodeAppBuilder(
    options: NodeAppOptions(srcDir: 'node', srcFile: 'raw_node.dart'),
  );
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}

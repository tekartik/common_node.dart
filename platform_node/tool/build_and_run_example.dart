import 'package:process_run/shell.dart';
import 'package:tekartik_build_node/build_node.dart';

Future main() async {
  await nodeBuild(directory: 'node_example');
  var shell = Shell();
  await shell.run('''
  node build/node_example/platform_context_node_example.dart.js
  ''');
}

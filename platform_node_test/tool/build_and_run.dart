import 'package:process_run/shell.dart';
import 'package:tekartik_build_node/build_node.dart';

Future main() async {
  await nodeBuild();
  var shell = Shell();

  await shell.run('''
  node build/node/main.dart.js argtmp
  ''');
}

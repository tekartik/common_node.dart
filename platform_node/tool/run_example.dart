import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
  pub run build_runner build example --output=example:build
  node build/platform_context_node_example.dart.js
  ''');
}

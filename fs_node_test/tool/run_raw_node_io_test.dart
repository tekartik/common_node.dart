import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

dart test -p node test/node/raw_node_io_test.dart

''');
}

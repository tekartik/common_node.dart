import 'package:process_run/shell.dart';

Future<void> main() async {
  var shell = Shell();

  await shell.run('''

dart test -p node test/http_node_test.dart

''');
}

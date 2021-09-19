import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

dart test -p node -N "client_server make post request with a body" test/http_node_test.dart

''');
}

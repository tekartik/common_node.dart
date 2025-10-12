import 'package:fs_shim/fs_io.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_stdio_node/src/readline.dart';

/// readline for io
final Readline readlineIo = ReadlineIo();

/// Readline implementation for dart:io
class ReadlineIo implements Readline {
  @override
  Future<String> question(String query) async {
    stdout.write(query);
    return (await sharedStdIn.nextLine());
  }

  @override
  void close() {
    sharedStdIn.terminate();
    // Logic for closing resources can be implemented here
  }
}

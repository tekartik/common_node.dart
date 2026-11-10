import 'dart:async';

import 'package:fs_shim/fs_io.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_stdio_node/src/readline.dart';

/// readline for io
final Readline readlineIo = ReadlineIo();

/// Readline implementation for dart:io
class ReadlineIo implements Readline {
  var _closed = false;

  @override
  Future<String> question(String query) async {
    stdout.write(query);
    return (await sharedStdIn.nextLine());
  }

  /// Terminates `sharedStdIn` so that the program can exit, once: a second
  /// call does nothing. `sharedStdIn` cannot be read again afterwards.
  @override
  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    // Already terminated elsewhere (process_run promptTerminate()...): fine.
    unawaited(sharedStdIn.terminate().catchError((Object _) {}));
  }
}

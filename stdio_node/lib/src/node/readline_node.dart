import 'dart:js_interop';

import 'package:tekartik_stdio_node/readline.dart';
import 'package:tekartik_stdio_node/src/node/process_interop.dart';
import 'package:tekartik_stdio_node/src/node/readline_interop.dart';

/// Readline for Node.js
final Readline readlineNode = _ReadlineNode();

class _ReadlineNode implements Readline {
  /// Created on first use (it holds stdin, preventing node from exiting until
  /// closed) and created again after [close].
  JsReadline? _impl;

  JsReadline get impl =>
      _impl ??= jsReadlineModule.createInterface(jsStdin, jsStdout);

  @override
  String toString() => 'ReadlineNode';

  @override
  void close() {
    _impl?.close();
    _impl = null;
  }

  @override
  Future<String> question(String prompt) async {
    var jsAnswer = ((await impl.question(prompt).toDart) as JSString).toDart;
    return jsAnswer;
  }
}

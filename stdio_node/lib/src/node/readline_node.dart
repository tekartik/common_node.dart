import 'dart:js_interop';

import 'package:tekartik_stdio_node/readline.dart';
import 'package:tekartik_stdio_node/src/node/process_interop.dart';
import 'package:tekartik_stdio_node/src/node/readline_interop.dart';

var _jsReadlineDefaultInterface = jsReadlineModule.createInterface(
  jsStdin,
  jsStdout,
);

/// Readline for Node.js
final Readline readlineNode = _ReadlineNode(impl: _jsReadlineDefaultInterface);

class _ReadlineNode implements Readline {
  final JsReadline impl;

  _ReadlineNode({required this.impl});

  @override
  String toString() => 'ReadlineNode';

  @override
  void close() async {}

  @override
  Future<String> question(String prompt) async {
    var jsAnswer = ((await impl.question(prompt).toDart) as JSString).toDart;
    return jsAnswer;
  }
}

import 'dart:js_interop';

JSAny get jsStdin => jsProcess.stdin;
JSAny get jsStdout => jsProcess.stdout;
extension type JsProcessStdio._(JSObject _) implements JSObject {
  /// Stdin
  external JSAny get stdin;

  /// Stdout
  external JSAny get stdout;

  external void exit(int code);
}
@JS('process')
external JsProcessStdio get jsProcessModule;

/// Compat
JsProcessStdio get jsProcess => jsProcessModule;

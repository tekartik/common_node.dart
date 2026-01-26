import 'dart:js_interop';

/// Stdin.
JSAny get jsStdin => jsProcess.stdin;

/// Stdout.
JSAny get jsStdout => jsProcess.stdout;

/// JS Process stdio.
extension type JsProcessStdio._(JSObject _) implements JSObject {
  /// Stdin
  external JSAny get stdin;

  /// Stdout
  external JSAny get stdout;

  /// Exit.
  external void exit(int code);

  /// Current directory
  external String cwd();
}
@JS('process')
/// JS Process module.
external JsProcessStdio get jsProcessModule;

/// Compat
JsProcessStdio get jsProcess => jsProcessModule;

import 'dart:js_interop';

/// JS Stdin.
JSAny get jsStdin => jsProcess.stdin;

/// JS Stdout.
JSAny get jsStdout => jsProcess.stdout;

/// JS Process stdio.
extension type JsProcessStdio._(JSObject _) implements JSObject {
  /// Stdin
  external JSAny get stdin;

  /// Stdout
  external JSAny get stdout;

  /// Exit the process.
  external void exit(int code);
}

/// JS Process module.
/// JS Process module.
@JS('process')
external JsProcessStdio get jsProcessModule;

/// JS Process instance.
JsProcessStdio get jsProcess => jsProcessModule;

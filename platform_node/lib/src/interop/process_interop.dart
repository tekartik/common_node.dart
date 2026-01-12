import 'dart:js_interop';

/// JS Process instance.
@JS()
extension type Process._(JSObject _) implements JSObject {
  /// node version
  external String get version;

  /// Stdin
  external JSAny get input;

  /// Stdout
  external JSAny get output;
}

/// JS Process instance.
@JS()
external Process get process;

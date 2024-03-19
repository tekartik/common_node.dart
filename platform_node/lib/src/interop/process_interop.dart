import 'dart:js_interop';

@JS()
extension type Process._(JSObject _) implements JSObject {
  /// node version
  external String get version;
}

@JS()
external Process get process;

import 'dart:js_interop' as js;

import 'package:tekartik_core_node/require.dart';

//FileSystem get fileSystemNode => io_node.fileSystem;
/// JS Readline module.
final jsReadlineModule = require<JsReadlineModule>('node:readline/promises');

/// JS Readline module.
extension type JsReadlineModule._(js.JSObject _) implements js.JSObject {}

/// JS Readline interface options.
extension type JsReadlineInterfaceOptions._(js.JSObject _)
    implements js.JSObject {
  /// Input.
  external js.JSAny get input;

  /// Constructor.
  external JsReadlineInterfaceOptions({js.JSAny input, js.JSAny output});
}

/// JS Readline module extension.
extension JsReadlineModuleExt on JsReadlineModule {
  /// Create interface.
  external JsReadline createInterface(js.JSAny input, js.JSAny output);
}

/// JS Readline.
/// JS Readline.
extension type JsReadline._(js.JSObject _) implements js.JSObject {
  /// Prompts a query to the user and returns the user's input.
  external js.JSPromise<js.JSAny> question(String query);

  /// Close.
  external void close();
}

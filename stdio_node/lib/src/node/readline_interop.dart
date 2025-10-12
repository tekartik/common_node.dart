import 'dart:js_interop' as js;

import 'package:tekartik_core_node/require.dart';

//FileSystem get fileSystemNode => io_node.fileSystem;
final jsReadlineModule = require<JsReadlineModule>('node:readline/promises');

extension type JsReadlineModule._(js.JSObject _) implements js.JSObject {}
extension type JsReadlineInterfaceOptions._(js.JSObject _)
    implements js.JSObject {
  external js.JSAny get input;
  external JsReadlineInterfaceOptions({js.JSAny input, js.JSAny output});
}

extension JsReadlineModuleExt on JsReadlineModule {
  external JsReadline createInterface(js.JSAny input, js.JSAny output);
}

extension type JsReadline._(js.JSObject _) implements js.JSObject {
  /// Prompts a query to the user and returns the user's input.
  external js.JSPromise<js.JSAny> question(String query);

  external void close();
}

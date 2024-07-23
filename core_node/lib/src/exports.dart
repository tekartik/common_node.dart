import 'dart:js_interop' as js;

@js.JS('exports')
external JSExports get exports;

extension type JSExports._(js.JSObject _) implements js.JSObject {}

extension JSExportsExt on JSExports {}

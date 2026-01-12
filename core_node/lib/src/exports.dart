import 'dart:js_interop' as js;

@js.JS('exports')
/// Exports.
external JSExports get exports;

/// JS Exports.
extension type JSExports._(js.JSObject _) implements js.JSObject {}

/// JS Exports extension.
extension JSExportsExt on JSExports {}

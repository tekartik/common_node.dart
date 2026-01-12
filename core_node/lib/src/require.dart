@JS()
library;

import 'dart:js_interop';

@JS('require')
external JSAny? _require(String module);

/// Require a module.
T require<T extends JSObject>(String module) => _require(module) as T;

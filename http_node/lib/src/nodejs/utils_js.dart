import 'dart:js_interop';

/// Get own property names.
@JS('Object.getOwnPropertyNames')
external JSAny getOwnPropertyNames(JSAny obj);

/// Get keys.
@JS('Object.keys')
external JSAny getKeys(JSAny obj);

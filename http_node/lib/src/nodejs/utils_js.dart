import 'dart:js_interop';

@JS('Object.getOwnPropertyNames')
external JSAny getOwnPropertyNames(JSAny obj);
@JS('Object.keys')
external JSAny getKeys(JSAny obj);

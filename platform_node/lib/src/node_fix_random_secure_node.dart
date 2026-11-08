import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

/// Whether reading `crypto` on dart2js' global context works.
bool get _selfCryptoReadable {
  try {
    return js.globalContext['crypto'] != null;
  } catch (_) {
    return false;
  }
}

/// Makes `Random.secure()` work in a dart2js node program, to call before the
/// first `Random.secure()`, typically first in a `dart test -p node` main.
///
/// The node preamble (`dart test -p node`, build_node) makes `self`, dart2js'
/// global context, an `Object.create(globalThis)`; `Random.secure()` reads
/// `self.crypto` and the node `crypto` getter rejects such a `this`
/// (ERR_INVALID_THIS). Gives `self` its own `crypto`, the one of the real
/// global object. build_node output already has it.
///
/// Returns true if the fix was applied, false when not needed (VM, browser,
/// already fixed) or not possible (no global crypto).
bool nodeFixRandomSecure() {
  if (_selfCryptoReadable) {
    return false;
  }
  var self = js.globalContext;
  var global = self['globalThis'] as js.JSObject?;
  var crypto = global?['crypto'];
  if (global == null || crypto == null) {
    return false;
  }
  var descriptor = js.JSObject()
    ..['value'] = crypto
    ..['writable'] = true.toJS
    ..['configurable'] = true.toJS
    ..['enumerable'] = true.toJS;
  (global['Object'] as js.JSObject).callMethod<js.JSAny?>(
    'defineProperty'.toJS,
    self,
    'crypto'.toJS,
    descriptor,
  );
  return true;
}

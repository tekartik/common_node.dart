import 'dart:async';
import 'dart:js_interop';

import 'http_interop.dart';
import 'utils_js.dart';

/// New implementation
class HttpNodeJs {
  final _jsHttpNode = jsHttpNode;
  HttpNodeJs._();

  /// Create a server.
  HttpServerJs createServer(
    FutureOr<void> Function(IncomingMessage req, ServerResponse res)
    requestListener,
  ) {
    var jsServer = _jsHttpNode.createServer(
      (IncomingMessage req, ServerResponse res) {
        requestListener(req, res);
      }.toJS,
    );
    return HttpServerJs._(jsServer);
  }
}

/// Global http node instance.
HttpNodeJs get httpNodeJs => HttpNodeJs._();

/// JS Http address.
class HttpAddressJs {
  final JsAddress _jsAddress;

  HttpAddressJs._(this._jsAddress);

  /// Port.
  int get port => _jsAddress.port;

  /// Address.
  String get address => _jsAddress.address;

  /// Family.
  String get family => _jsAddress.family;

  /// To map.
  Map<String, Object?> toMap() => <String, Object?>{
    'port': port,
    'address': address,
    'family': family,
  };
  @override
  String toString() => toMap().toString();
}

/// JS Http server.
class HttpServerJs {
  final JsServer _jsServer;

  HttpServerJs._(this._jsServer);

  /// Address.
  HttpAddressJs address() {
    return HttpAddressJs._(_jsServer.address());
  }

  /// Listen.
  Future<void> listen({int? port, String? hostname}) {
    port ??= 0;
    hostname ??= 'localhost';
    var completer = Completer<void>();
    try {
      _jsServer.listen(
        port,
        hostname,
        () {
          // ignore: avoid_print
          print('server listening');
          // ignore: avoid_print
          print(getOwnPropertyNames(_jsServer.address()));
          completer.complete();
        }.toJS,
      );
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }
}

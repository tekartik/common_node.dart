import 'dart:async';
import 'dart:js_interop';

import 'http_interop.dart';
import 'utils_js.dart';

/// New implementation
class HttpNodeJs {
  final _jsHttpNode = jsHttpNode;
  HttpNodeJs._();
  HttpServerJs createServer(
      void Function(IncomingMessage req, ServerResponse res) requestListener) {
    var jsServer =
        _jsHttpNode.createServer((IncomingMessage req, ServerResponse res) {
      print('req: $req');
    }.toJS);
    return HttpServerJs._(jsServer);
  }
}

HttpNodeJs get httpNodeJs => HttpNodeJs._();

class HttpAddressJs {
  final JsAddress _jsAddress;

  HttpAddressJs._(this._jsAddress);

  int get port => _jsAddress.port;
  String get address => _jsAddress.address;
  String get family => _jsAddress.family;

  Map<String, Object?> toMap() => <String, Object?>{
        'port': port,
        'address': address,
        'family': family,
      };
  @override
  String toString() => toMap().toString();
}

class HttpServerJs {
  final JsServer _jsServer;

  HttpServerJs._(this._jsServer);

  HttpAddressJs address() {
    return HttpAddressJs._(_jsServer.address());
  }

  Future<void> listen({int? port, String? hostname}) {
    port ??= 0;
    hostname ??= 'localhost';
    var completer = Completer<void>();
    try {
      _jsServer.listen(
          port,
          hostname,
          () {
            print('server listening');
            print(getOwnPropertyNames(_jsServer.address()));
            completer.complete();
          }.toJS);
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }
}

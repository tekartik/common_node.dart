import 'dart:async';
import 'dart:typed_data';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http_server.dart';

import 'node/import_node.dart' as node;

/// Convert to a native internet address case by case...
dynamic unwrapInternetAddress(dynamic address) {
  if (address is InternetAddress) {
    if (address == InternetAddress.anyIPv4) {
      address = '0.0.0.0';
    } else {
      throw 'address $address not supported';
    }
  }
  return address;
}

class HttpServerFactoryNode implements HttpServerFactory {
  int lastDynamicPort = 33000;

  @override
  Future<HttpServer> bind(address, int port) async {
    if (port == 0) {
      port = lastDynamicPort;
    }
    address = unwrapInternetAddress(address);
    while (true) {
      try {
        var server = await node.HttpServer.bind(address, port);
        lastDynamicPort = server.port;
        return HttpServerNode(server);
      } catch (_) {
        port++;
        if (port > lastDynamicPort + 1000) {
          rethrow;
        }
      }
    }
  }
}

class HttpServerNode extends Stream<HttpRequest> implements HttpServer {
  final node.HttpServer ioHttpServer;

  HttpServerNode(this.ioHttpServer);

  @override
  Future close({bool force = false}) => ioHttpServer.close(force: force);

  @override
  StreamSubscription<HttpRequest> listen(
      void Function(HttpRequest event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return ioHttpServer.transform<HttpRequest>(
        StreamTransformer<HttpRequest, HttpRequest>.fromHandlers(
            handleData: (request, sink) {
      sink.add(HttpRequestNode(request as node.NodeHttpRequest));
    })).listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  @override
  int get port => ioHttpServer.port;

  @override
  InternetAddress? get address => ioHttpServer.address;
}

class HttpRequestNode extends Stream<Uint8List> implements HttpRequest {
  final node.NodeHttpRequest nodeHttpRequest;

  HttpRequestNode(this.nodeHttpRequest);

  @override
  int? get contentLength => nodeHttpRequest.contentLength;

  @override
  HttpHeaders get headers => nodeHttpRequest.headers;

  @override
  String get method => nodeHttpRequest.method;

  @override
  Uri get requestedUri => nodeHttpRequest.requestedUri;

  @override
  HttpResponse get response => nodeHttpRequest.response;

  @override
  Uri get uri => nodeHttpRequest.uri;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return nodeHttpRequest.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

HttpServerFactoryNode? _httpServerFactoryNode;

HttpServerFactoryNode get httpServerFactoryNode =>
    _httpServerFactoryNode ??= HttpServerFactoryNode();

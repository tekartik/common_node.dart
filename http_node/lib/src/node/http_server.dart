// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:async';

//import 'dart:js_util' as jsu;
import 'dart:typed_data';

import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as jsu;
import 'package:node_interop/http.dart' as http_node;
import 'package:tekartik_common_utils/common_utils_import.dart';

// ignore: implementation_imports
import 'package:tekartik_fs_node/src/node/streams.dart';

import 'http_common.dart' as common;
import 'http_headers.dart';
import 'internet_address.dart';

/*
export 'dart:io'
    show
        HttpDate,
        HttpStatus,
        HttpHeaders,
        HeaderValue,
        ContentType,
        Cookie,
        HttpException,
        HttpRequest,
        HttpResponse,
        HttpConnectionInfo;
*/
List<int> _asIntList(dynamic list) =>
    list is List<int> ? list : (list as List).cast<int>();

/// A server that delivers content, such as web pages, using the HTTP protocol.
///
/// The HttpServer is a [Stream] that provides [HttpRequest] objects. Each
/// HttpRequest has an associated [HttpResponse] object.
/// The server responds to a request by writing to that HttpResponse object.
/// The following example shows how to bind an HttpServer to an IPv6
/// [InternetAddress] on port 80 (the standard port for HTTP servers)
/// and how to listen for requests.
/// Port 80 is the default HTTP port. However, on most systems accessing
/// this requires super-user privileges. For local testing consider
/// using a non-reserved port (1024 and above).
///
///     import 'dart:io';
///
///     main() {
///       HttpServer
///           .bind(InternetAddress.anyIPv6, 80)
///           .then((server) {
///             server.listen((HttpRequest request) {
///               request.response.write('Hello, world!');
///               request.response.close();
///             });
///           });
///     }
///
/// Incomplete requests, in which all or part of the header is missing, are
/// ignored, and no exceptions or HttpRequest objects are generated for them.
/// Likewise, when writing to an HttpResponse, any [Socket] exceptions are
/// ignored and any future writes are ignored.
///
/// The HttpRequest exposes the request headers and provides the request body,
/// if it exists, as a Stream of data. If the body is unread, it is drained
/// when the server writes to the HttpResponse or closes it.
abstract class HttpServer implements common.HttpServer {
  /// Starts listening for HTTP requests on the specified [address] and
  /// [port].
  ///
  /// The [address] can either be a [String] or an
  /// [InternetAddress]. If [address] is a [String], [bind] will
  /// perform a [InternetAddress.lookup] and use the first value in the
  /// list. To listen on the loopback adapter, which will allow only
  /// incoming connections from the local host, use the value
  /// [InternetAddress.loopbackIPv4] or
  /// [InternetAddress.loopbackIPv6]. To allow for incoming
  /// connection from the network use either one of the values
  /// [InternetAddress.anyIPv4] or [InternetAddress.anyIPv6] to
  /// bind to all interfaces or the IP address of a specific interface.
  ///
  /// If an IP version 6 (IPv6) address is used, both IP version 6
  /// (IPv6) and version 4 (IPv4) connections will be accepted. To
  /// restrict this to version 6 (IPv6) only, use [v6Only] to set
  /// version 6 only. However, if the address is
  /// [InternetAddress.loopbackIPv6], only IP version 6 (IPv6) connections
  /// will be accepted.
  ///
  /// If [port] has the value [:0:] an ephemeral port will be chosen by
  /// the system. The actual port used can be retrieved using the
  /// [port] getter.
  ///
  /// The optional argument [backlog] can be used to specify the listen
  /// backlog for the underlying OS listen setup. If [backlog] has the
  /// value of [:0:] (the default) a reasonable value will be chosen by
  /// the system.
  ///
  /// The optional argument [shared] specifies whether additional HttpServer
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.
  static Future<HttpServer> bind(Object? address, int port,
          {int backlog = 0, bool v6Only = false, bool shared = false}) =>
      _HttpServer.bind(address, port,
          backlog: backlog, v6Only: v6Only, shared: shared);
}

class _HttpServer extends Stream<common.HttpRequest> implements HttpServer {
  @override
  final InternetAddress address;
  @override
  final int port;

  late http_node.HttpServer _server;
  Completer<HttpServer>? _listenCompleter;
  late StreamController<common.HttpRequest> _controller;

  _HttpServer._(this.address, this.port) {
    _controller = StreamController<common.HttpRequest>(
      onListen: _onListen,
      onPause: _onPause,
      onResume: _onResume,
      onCancel: _onCancel,
    );
    _server = http_node.http.createServer(js.allowInterop(_jsRequestHandler));
    _server.on('error', js.allowInterop(_jsErrorHandler));
  }

  void _onListen() {}

  void _onPause() {}

  void _onResume() {}

  void _onCancel() {
    _server.close();
  }

  void _jsErrorHandler(Object error) {
    if (_listenCompleter != null) {
      _listenCompleter!.completeError(error);
      _listenCompleter = null;
    }
    _controller.addError(error);
  }

  void _jsRequestHandler(
      http_node.IncomingMessage request, http_node.ServerResponse response) {
    if (_controller.isPaused) {
      // Reject any incoming request before listening started or subscription
      // is paused.
      response.statusCode = common.httpStatusCodeServiceUnavailable;
      response.end();
      return;
    }
    _controller.add(NodeHttpRequest(request, response));
  }

  Future<HttpServer> _bind() {
    assert(_server.listening && _listenCompleter == null);

    _listenCompleter = Completer<HttpServer>();
    void listeningHandler() {
      _listenCompleter!.complete(this);
      _listenCompleter = null;
    }

    _server.listen(
        port, address.address, null, js.allowInterop(listeningHandler));
    return _listenCompleter!.future;
  }

  static Future<HttpServer> bind(Object? address, int port,
      {int backlog = 0, bool v6Only = false, bool shared = false}) async {
    assert(!shared, 'Shared is not implemented yet');

    if (address is String) {
      var list = (await InternetAddress.lookup(address.toString()))
          .cast<InternetAddress>();
      address = list.first;
    }
    var server = _HttpServer._(address as InternetAddress, port);
    return server._bind();
  }

  /*
  @override
  late bool autoCompress; // TODO: Implement autoCompress

  @override
  Duration? idleTimeout; // TODO: Implement idleTimeout

  @override
  String? serverHeader; // TODO: Implement serverHeader

   */

  @override
  Future close({bool force = false}) {
    assert(!force, 'Force argument is not supported by Node HTTP server');
    final completer = Completer<void>();
    _server.close(js.allowInterop(([error]) {
      _controller.close();
      if (error != null) {
        completer.complete(error);
      } else {
        completer.complete();
      }
    }));
    return completer.future;
  }

  /*
  @override
  HttpHeaders get defaultResponseHeaders => throw UnimplementedError();

   */

  @override
  StreamSubscription<common.HttpRequest> listen(
    void Function(common.HttpRequest event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

/*
  @override
  set sessionTimeout(int timeout) {
    throw UnimplementedError();
  }*/
}

/// Server side HTTP request object which delegates IO operations to
/// Node.js native representations.
class NodeHttpRequest implements common.HttpRequest, HasReadable {
  final ReadableStream<Uint8List> _delegate;
  final http_node.ServerResponse _nativeResponse;

  NodeHttpRequest(http_node.IncomingMessage nativeRequest, this._nativeResponse)
      : _delegate = ReadableStream(nativeRequest,
            convert: (chunk) => Uint8List.fromList(_asIntList(chunk)));

  @override
  http_node.IncomingMessage get nativeInstance =>
      _delegate.nativeInstance as http_node.IncomingMessage;

  /*
  @override
  HttpConnectionInfo get connectionInfo {
    var socket = nativeInstance.socket;
    var address = InternetAddress(socket.remoteAddress);
    return _HttpConnectionInfo(socket.localPort, address, socket.remotePort);
  }*/

  @override
  int get contentLength => // headers.contentLength;
      requestHeaders.contentLength;

  /*
  @override
  List<Cookie> get cookies {
    if (_cookies != null) return _cookies!;
    _cookies = <Cookie>[];
    final values = headers[HttpHeaders.setCookieHeader];
    if (values != null) {
      values.forEach((value) {
        _cookies!.add(Cookie.fromSetCookieValue(value));
      });
    }
    return _cookies!;
  }

  List<Cookie>? _cookies;
  */
  @override
  common.HttpHeaders get headers => requestHeaders;

  RequestHttpHeaders get requestHeaders =>
      _headers ??= RequestHttpHeaders(nativeInstance);
  RequestHttpHeaders? _headers;

  @override
  String get method => nativeInstance.method;

  /*
  @override
  bool get persistentConnection => requestHeaders.persistentConnection;

  @override
  String get protocolVersion => nativeInstance.httpVersion;
  */
  @override
  Uri get requestedUri {
    if (_requestedUri == null) {
      var socket = nativeInstance.socket;

      var proto = headers['x-forwarded-proto'];
      String scheme;
      if (proto != null) {
        scheme = proto.first;
      } else {
        var isSecure = (jsu.getProperty(socket, 'encrypted') as bool?) ?? false;
        scheme = isSecure ? 'https' : 'http';
      }
      var hostList = headers['x-forwarded-host'];
      String host;
      if (hostList != null) {
        host = hostList.first;
      } else {
        hostList = headers['host'];
        if (hostList != null) {
          host = hostList.first;
        } else {
          host = '${socket.localAddress}:${socket.localPort}';
        }
      }
      _requestedUri = Uri.parse('$scheme://$host$uri');
    }
    return _requestedUri!;
  }

  Uri? _requestedUri;

  @override
  common.HttpResponse get response =>
      _response ??= NodeHttpResponse(_nativeResponse);
  NodeHttpResponse? _response; // ignore: close_sinks

  /*
  @override
  common.HttpSession get session =>
      throw UnsupportedError('Sessions are not supported by Node HTTP server.');

   */

  @override
  Uri get uri => Uri.parse(nativeInstance.url);

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _delegate.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    return _delegate.any(test);
  }

  @override
  Stream<Uint8List> asBroadcastStream({
    void Function(StreamSubscription<Uint8List> subscription)? onListen,
    void Function(StreamSubscription<Uint8List> subscription)? onCancel,
  }) {
    return _delegate.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    return _delegate.asyncExpand<E>(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    return _delegate.asyncMap<E>(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _delegate.cast<R>();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _delegate.contains(needle);
  }

  @override
  Stream<Uint8List> distinct(
      [bool Function(Uint8List previous, Uint8List next)? equals]) {
    return _delegate.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _delegate.drain<E>(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    return _delegate.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    return _delegate.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    return _delegate.expand(convert);
  }

  @override
  Future<Uint8List> get first => _delegate.first;

  @override
  Future<Uint8List> firstWhere(
    bool Function(Uint8List element) test, {
    List<int> Function()? orElse,
  }) {
    return _delegate.firstWhere(test, orElse: () {
      return Uint8List.fromList(orElse!());
    });
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Uint8List element) combine) {
    return _delegate.fold<S>(initialValue, combine);
  }

  @override
  Future<dynamic> forEach(void Function(Uint8List element) action) {
    return _delegate.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(
    Function onError, {
    bool Function(dynamic error)? test,
  }) {
    return _delegate.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => _delegate.isBroadcast;

  @override
  Future<bool> get isEmpty => _delegate.isEmpty;

  @override
  Future<String> join([String separator = '']) {
    return _delegate.join(separator);
  }

  @override
  Future<Uint8List> get last => _delegate.last;

  @override
  Future<Uint8List> lastWhere(
    bool Function(Uint8List element) test, {
    List<int> Function()? orElse,
  }) {
    return _delegate.lastWhere(test, orElse: () {
      return Uint8List.fromList(orElse!());
    });
  }

  @override
  Future<int> get length => _delegate.length;

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    return _delegate.map<S>(convert);
  }

  @override
  Future<dynamic> pipe(StreamConsumer<List<int>> streamConsumer) {
    return _delegate.cast<List<int>>().pipe(streamConsumer);
  }

  @override
  Future<Uint8List> reduce(
      List<int> Function(Uint8List previous, Uint8List element) combine) {
    return _delegate.reduce((p, e) => Uint8List.fromList(combine(p, e)));
  }

  @override
  Future<Uint8List> get single => _delegate.single;

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {List<int> Function()? orElse}) {
    return _delegate.singleWhere(test, orElse: () {
      return Uint8List.fromList(orElse!());
    });
  }

  @override
  Stream<Uint8List> skip(int count) {
    return _delegate.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    return _delegate.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    return _delegate.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    return _delegate.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(
    Duration timeLimit, {
    void Function(EventSink<Uint8List> sink)? onTimeout,
  }) {
    return _delegate.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<Uint8List>> toList() {
    return _delegate.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    return _delegate.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return _delegate.cast<List<int>>().transform<S>(streamTransformer);
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    return _delegate.where(test);
  }
}

/// Server side HTTP response object which delegates IO operations to
/// Node.js native representations.
class NodeHttpResponse extends NodeUint8ListSink
    implements common.HttpResponse {
  NodeHttpResponse(http_node.ServerResponse super.nativeResponse);

  //@override
  http_node.ServerResponse get nativeResponse =>
      nativeInstance as http_node.ServerResponse;

  /*
  @override
  bool get bufferOutput => throw UnimplementedError();

  @override
  set bufferOutput(bool buffer) {
    throw UnimplementedError();
  }
  */
  @override
  int get contentLength => throw UnimplementedError();

  @override
  set contentLength(int length) {
    throw UnimplementedError();
  }

  /*
  @override
  Duration get deadline => throw UnimplementedError();

  @override
  set deadline(Duration? value) {
    throw UnimplementedError();
  }*/

  /*
  @override
  bool get persistentConnection => headers.persistentConnection;

  @override
  set persistentConnection(bool persistent) {
    headers.persistentConnection = persistent;
  }*/

  /*
  @override
  String get reasonPhrase => nativeResponse.statusMessage;

  @override
  set reasonPhrase(String phrase) {
    if (nativeResponse.headersSent) {
      throw StateError('Headers already sent.');
    }
    nativeResponse.statusMessage = phrase;
  }
  */
  @override
  int get statusCode => nativeResponse.statusCode.round();

  @override
  set statusCode(int code) {
    if (nativeResponse.headersSent) {
      throw StateError('Headers already sent.');
    }
    nativeResponse.statusCode = code;
  }

  @override
  Future close() {
    var responseHeaders = headers as ResponseHttpHeaders;
    responseHeaders.finalize();
    return super.close();
  }

  /*
  @override
  HttpConnectionInfo get connectionInfo {
    var socket = nativeInstance.socket;
    var address = InternetAddress(socket.remoteAddress);
    return _HttpConnectionInfo(socket.localPort, address, socket.remotePort);
  }

  @override
  List<Cookie> get cookies {
    if (_cookies != null) return _cookies!;
    _cookies = <Cookie>[];
    final values = headers[HttpHeaders.setCookieHeader];
    if (values != null) {
      values.forEach((value) {
        _cookies!.add(Cookie.fromSetCookieValue(value));
      });
    }
    return _cookies!;
  }

  List<Cookie>? _cookies;

  @override
  Future<Socket> detachSocket({bool writeHeaders = true}) {
    throw UnimplementedError();
  }
  */
  @override
  HttpHeaders get headers => _headers ??= ResponseHttpHeaders(nativeResponse);
  ResponseHttpHeaders? _headers;

  @override
  Future redirect(Uri location,
      {int status = common.NodeHttpStatus.movedTemporarily}) {
    statusCode = status;
    headers.set('location', '$location');
    return close();
  }
}

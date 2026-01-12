// ignore_for_file: non_constant_identifier_names

@JS()
library;

import 'dart:js_interop';

import 'package:tekartik_core_node/require.dart';

/// JS Address.
extension type JsAddress._(JSObject _) implements JSObject {
  /// Port.
  external int get port;

  /// Address.
  external String get address;

  /// Family.
  external String get family;
}

/// Incoming message.
extension type IncomingMessage._(JSObject _) implements JSObject {}

/// Server response.
extension type ServerResponse._(JSObject _) implements JSObject {}
// [_connectionListener, METHODS, STATUS_CODES, Agent, ClientRequest,
// IncomingMessage, OutgoingMessage, Server, ServerResponse, createServer, validateHeaderName, validateHeaderValue, get, request, setMaxIdleHTTPParsers, maxHeaderSize, globalAgent]
/// JS Http node.
extension type JsHttpNode._(JSObject _) implements JSObject {
  /// Agent.
  external JSObject get Agent;

  /// Client request.
  external JSObject get ClientRequest;

  /// Incoming message.
  external JSObject get IncomingMessage_;

  /// Outgoing message.
  external JSObject get OutgoingMessage_;

  /// Server.
  external JSObject get Server;

  /// Server response.
  external JSObject get ServerResponse_;

  /// Create server.
  external JsServer createServer(JSFunction requestListener);

  /// Validate header name.
  external void validateHeaderName(String name);

  /// Validate header value.
  external void validateHeaderValue(String name, String value);

  /// Global agent.
  external JSObject get globalAgent;

  /// Methods.
  external JSObject get METHODS;

  /// Status codes.
  external JSObject get STATUS_CODES;

  /// Get.
  external JSObject get get;

  /// Request.
  external JSObject get request;

  /// Set max idle http parsers.
  external void setMaxIdleHTTPParsers(int value);

  /// Max header size.
  external int get maxHeaderSize;
}

/// JS Server.
extension type JsServer._(JSObject _) implements JSObject {
  /// Listen.
  external void listen(int port, String hostname, JSFunction callback);

  /// Address.
  external JsAddress address();
}

/// JS Http node instance.
JsHttpNode get jsHttpNode => require<JsHttpNode>('node:http');

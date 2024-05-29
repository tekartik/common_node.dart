// ignore_for_file: non_constant_identifier_names

@JS()
library;

import 'dart:js_interop';

import 'package:tekartik_core_node/require.dart';

extension type JsAddress._(JSObject _) implements JSObject {
  external int get port;
  external String get address;
  external String get family;
}

extension type IncomingMessage._(JSObject _) implements JSObject {}
extension type ServerResponse._(JSObject _) implements JSObject {}
// [_connectionListener, METHODS, STATUS_CODES, Agent, ClientRequest,
// IncomingMessage, OutgoingMessage, Server, ServerResponse, createServer, validateHeaderName, validateHeaderValue, get, request, setMaxIdleHTTPParsers, maxHeaderSize, globalAgent]
extension type JsHttpNode._(JSObject _) implements JSObject {
  external JSObject get Agent;
  external JSObject get ClientRequest;
  external JSObject get IncomingMessage_;
  external JSObject get OutgoingMessage_;
  external JSObject get Server;
  external JSObject get ServerResponse_;
  external JsServer createServer(JSFunction requestListener);
  external void validateHeaderName(String name);
  external void validateHeaderValue(String name, String value);
  external JSObject get globalAgent;
  external JSObject get METHODS;
  external JSObject get STATUS_CODES;
  external JSObject get get;
  external JSObject get request;
  external void setMaxIdleHTTPParsers(int value);
  external int get maxHeaderSize;
}

extension type JsServer._(JSObject _) implements JSObject {
  external void listen(int port, String hostname, JSFunction callback);
  external JsAddress address();
}
JsHttpNode get jsHttpNode => require<JsHttpNode>('node:http');

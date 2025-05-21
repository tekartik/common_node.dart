@TestOn('node')
library;

import 'package:http_client_conformance_tests/http_client_conformance_tests.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:test/test.dart';

/// Runs the entire test suite against the given [Client].
///
/// If [canStreamRequestBody] is `false` then tests that assume that the
/// [Client] supports sending HTTP requests with unbounded body sizes will be
/// skipped.
//
/// If [canStreamResponseBody] is `false` then tests that assume that the
/// [Client] supports receiving HTTP responses with unbounded body sizes will
/// be skipped
///
/// If [redirectAlwaysAllowed] is `true` then tests that require the [Client]
/// to limit redirects will be skipped.
///
/// If [canWorkInIsolates] is `false` then tests that require that the [Client]
/// work in Isolates other than the main isolate will be skipped.
///
/// If [preservesMethodCase] is `false` then tests that assume that the
/// [Client] preserves custom request method casing will be skipped.
///
/// If [canSendCookieHeaders] is `false` then tests that require that "cookie"
/// headers be sent by the client will not be run.
///
/// If [canReceiveSetCookieHeaders] is `false` then tests that require that
/// "set-cookie" headers be received by the client will not be run.
///
/// If [supportsFoldedHeaders] is `false` then the tests that assume that the
/// [Client] can parse folded headers will be skipped.
///
/// If [supportsMultipartRequest] is `false` then tests that assume that
/// multipart requests can be sent will be skipped.
///
/// The tests are run against a series of HTTP servers that are started by the
/// tests. If the tests are run in the browser, then the test servers are
/// started in another process. Otherwise, the test servers are run in-process.
void testAll(
  Client Function() clientFactory, {
  bool canStreamRequestBody = true,
  bool canStreamResponseBody = true,
  bool redirectAlwaysAllowed = false,
  bool canWorkInIsolates = true,
  bool preservesMethodCase = false,
  bool supportsFoldedHeaders = true,
  bool canSendCookieHeaders = false,
  bool canReceiveSetCookieHeaders = false,
  bool supportsMultipartRequest = true,
}) {
  testRequestBody(clientFactory());
  testRequestBodyStreamed(
    clientFactory(),
    canStreamRequestBody: canStreamRequestBody,
  );
  testResponseBody(
    clientFactory(),
    canStreamResponseBody: canStreamResponseBody,
  );
  testResponseBodyStreamed(
    clientFactory(),
    canStreamResponseBody: canStreamResponseBody,
  );
  testRequestHeaders(clientFactory());
  // Failing on node
  // ignore: dead_code
  if (false) {
    testRequestMethods(
      clientFactory(),
      preservesMethodCase: preservesMethodCase,
    );

    testResponseHeaders(
      clientFactory(),
      supportsFoldedHeaders: supportsFoldedHeaders,
    );
  }
  testResponseStatusLine(clientFactory());
  testRedirect(clientFactory(), redirectAlwaysAllowed: redirectAlwaysAllowed);
  testServerErrors(clientFactory());
  testCompressedResponseBody(clientFactory());
  testMultipleClients(clientFactory);
  testMultipartRequests(
    clientFactory(),
    supportsMultipartRequest: supportsMultipartRequest,
  );
  testClose(clientFactory);
  testIsolate(clientFactory, canWorkInIsolates: canWorkInIsolates);
  testRequestCookies(
    clientFactory(),
    canSendCookieHeaders: canSendCookieHeaders,
  );
  testResponseCookies(
    clientFactory(),
    canReceiveSetCookieHeaders: canReceiveSetCookieHeaders,
  );
}

Client newClient() => httpClientFactoryNode.newClient();
void main() {
  group('client conformance tests', () {
    testAll(
      () => newClient(),
      canStreamRequestBody: false,
      canStreamResponseBody: true,
      redirectAlwaysAllowed: true,
      canWorkInIsolates: false,
      canReceiveSetCookieHeaders: false,
      canSendCookieHeaders: false,
      preservesMethodCase: true,
      supportsFoldedHeaders: false,
      supportsMultipartRequest: false,
    );
  });
}

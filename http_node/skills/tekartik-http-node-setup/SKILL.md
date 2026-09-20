---
name: tekartik-http-node-setup
description: >-
  Use when Dart code compiled for Node.js needs an HTTP client through the
  tekartik_http abstraction with tekartik_http_node: httpClientFactoryNode
  and httpClientFactoryNodeFetch (a package:http Client over node's global
  fetch via fetch_client), httpClientFactoryUniversal (fetch on node, the
  dart:io client on the VM), the http_client_node.dart /
  http_client_node_fetch.dart / http_client_universal.dart imports, the
  httpClientRead / httpClientSend / httpClientReadBytes helpers, the node
  client limits (no request streaming, cookies or multipart) and running the
  shared tekartik_http_test echo server client suite with dart test -p node.
---

# tekartik_http_node: HTTP client on Node.js (tekartik_http_node)

`tekartik_http_node` provides `HttpClientFactory` implementations (from
`tekartik_http`) for Dart code compiled to JavaScript and run by Node.js. The
client is a regular `package:http` `Client` built on node's global `fetch`
(Node 18+). There is no node HTTP server in this package: it is client only.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_http_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: http_node
    tekartik_http:
      git:
        url: https://github.com/tekartik/http.dart
        path: http
  ```
* Imports: the three entry points all re-export
  `package:tekartik_http/http_client.dart` (`Client`, `HttpClientFactory`,
  `httpClientSend`, `httpClientRead`, `httpClientReadBytes`,
  `HttpClientResponse`, `httpClientFactoryMemory` and the constants
  `httpMethodGet`, `httpMethodPost`, `httpHeaderContentType`,
  `httpContentTypeJson`, ...):
  * `package:tekartik_http_node/http_client_node.dart` adds
    `httpClientFactoryNode`, the node factory (an alias of the fetch one).
  * `package:tekartik_http_node/http_client_node_fetch.dart` adds
    `httpClientFactoryNodeFetch` (`HttpClientFactoryNodeFetch`): `newClient()`
    returns a `fetch_client` `FetchClient`.
  * `package:tekartik_http_node/http_client_universal.dart` adds
    `httpClientFactoryUniversal`: the node fetch factory when running as
    JavaScript, `httpClientFactoryIo` from `tekartik_http_io` on the VM. Use
    it in code shared between a node build and a dart script.
* Off node: `httpClientFactoryNode` and `httpClientFactoryNodeFetch` throw
  `UnimplementedError` when accessed on the VM (importing is fine). Probe
  with `try { httpClientFactoryNode; } on UnimplementedError catch (_) {}`
  in multiplatform tests.
* Usage: `var client = factory.newClient();` then `client.close()` in a
  `finally`. The client is a `package:http` `Client` (`client.get(uri)`,
  `client.post(uri, body:)`, `client.send(request)`); the `tekartik_http`
  helpers take it as first argument: `httpClientRead(client, method, uri,
  {headers, body, encoding, responseEncoding})` returns the body text and
  throws on a non-2xx status, `httpClientReadBytes` the bytes,
  `httpClientSend(..., throwOnFailure:)` an `HttpClientResponse`
  (`statusCode`, `isSuccessful`, `body`, `bodyBytes`, `headers`). `body`
  may be a `String`, a `List<int>` or a `Map<String, String>` (form fields).
* Limits of the fetch client (from the `http_client_conformance_tests` run
  in the repo's `http_node_test`): request bodies are not streamed
  (responses are), redirects are always followed, cookie headers are neither
  sent nor received, folded headers and multipart requests are unsupported,
  no isolates. Design APIs around JSON bodies and explicit headers.
* Server side: implement servers with `tekartik_http_io`
  (`httpServerFactoryIo`) on the VM or `httpFactoryMemory` in tests; on node
  rely on the hosting framework (firebase functions, express) for requests.
* Tests: `@TestOn('node')` and `dart test -p node` (node on the PATH). The
  shared suite `runEchoServerClientTests(httpClientFactory)` from
  `package:tekartik_http_test/echo_server_client_test.dart` (git
  `https://github.com/tekartik/http.dart`, `path: http_test`) spawns an echo
  server in a VM process and exercises the client from the node test;
  `run(httpFactoryMemory)` from `http_test.dart` covers the memory factory.

## Examples

### GET on node

```dart
import 'package:tekartik_http_node/http_client_node.dart';

Future<void> main() async {
  var client = httpClientFactoryNode.newClient();
  try {
    var text = await httpClientRead(
      client,
      httpMethodGet,
      Uri.parse('https://example.com/'),
    );
    print(text.length);
  } finally {
    client.close();
  }
}
```

### JSON POST shared between node and the VM

```dart
import 'dart:convert';

import 'package:tekartik_http_node/http_client_universal.dart';

Future<Map<String, Object?>> postJson(Uri uri, Map<String, Object?> data) async {
  var client = httpClientFactoryUniversal.newClient();
  try {
    var text = await httpClientRead(
      client,
      httpMethodPost,
      uri,
      headers: {httpHeaderContentType: httpContentTypeJson},
      body: jsonEncode(data),
    );
    return jsonDecode(text) as Map<String, Object?>;
  } finally {
    client.close();
  }
}
```

### Inject the factory, inspect the response

```dart
import 'package:tekartik_http_node/http_client_universal.dart';

class ApiService {
  final HttpClientFactory httpClientFactory;
  final Uri baseUri;

  ApiService({required this.httpClientFactory, required this.baseUri});

  Future<int> ping() async {
    var client = httpClientFactory.newClient();
    try {
      var response = await httpClientSend(
        client,
        httpMethodGet,
        baseUri.resolve('ping'),
      );
      return response.statusCode;
    } finally {
      client.close();
    }
  }
}

void main() {
  var service = ApiService(
    httpClientFactory: httpClientFactoryUniversal,
    baseUri: Uri.parse('http://localhost:8080/'),
  );
  service.ping().then(print);
}
```

### Run the shared client suite on node

```dart
@TestOn('node')
library;

import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:test/test.dart';

void main() {
  runEchoServerClientTests(httpClientFactoryNode);
}
```

## Common mistakes

* Accessing `httpClientFactoryNode` in code that also runs on the VM: use
  `httpClientFactoryUniversal`.
* Sending multipart or cookie based requests from node.
* Looking for a node `HttpServerFactory` here: the package is client only.

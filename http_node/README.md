# tekartik_http_node

An HTTP client for Dart compiled to JavaScript and run by Node.js, behind the
`tekartik_http` `HttpClientFactory` abstraction: the client is a regular
`package:http` `Client` (`BrowserClient`) on node's global `fetch` (Node 18
or later). Client only: no HTTP server on node here.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_http_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: http_node
```

```dart
import 'package:tekartik_http_node/http_client_universal.dart';

Future<void> main() async {
  // fetch on node, dart:io on the Dart VM.
  var client = httpClientFactoryUniversal.newClient();
  try {
    var text = await httpClientRead(
      client,
      httpMethodGet,
      Uri.parse('https://tekartik-test-fixtures.web.app/http/connected.json'),
    );
    print(text);
  } finally {
    client.close();
  }
}
```

## Libraries and platforms

* `package:tekartik_http_node/http_client_node.dart`: `httpClientFactoryNode`
  (node only, throws `UnimplementedError` on the VM).
* `package:tekartik_http_node/http_client_node_fetch.dart`:
  `httpClientFactoryNodeFetch`, the same fetch client.
* `package:tekartik_http_node/http_client_universal.dart`:
  `httpClientFactoryUniversal`, the fetch client on node and
  `tekartik_http_io` on the VM, for code shared by both.

All three re-export `package:tekartik_http/http_client.dart`
(`httpClientRead`, `httpClientSend`, the method and header constants).

## Common pitfalls

* Close each client (`client.close()` in a `finally`).
* `followRedirects = false` throws a `ClientException` on a redirect (fetch
  `redirect: 'error'`): there is no 3xx response to read on node.
* No request body streaming, cookies, multipart requests nor isolates: see
  [doc/http_node.md](doc/http_node.md).
* Tests: `dart test -p node`; the shared client suites (conformance, echo
  server) run in `http_node_test` of this repository.

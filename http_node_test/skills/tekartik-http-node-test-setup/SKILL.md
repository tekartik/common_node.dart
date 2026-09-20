---
name: tekartik-http-node-test-setup
description: >-
  Use when running or extending the tekartik_http conformance suites against
  the Node.js HTTP client with tekartik_http_node_test: runEchoServerClientTests
  from tekartik_http_test/echo_server_client_test.dart against
  httpClientFactoryNode, httpClientFactoryNodeFetch and
  httpClientFactoryUniversal, run(httpFactoryMemory) from http_test.dart,
  the package:http_client_conformance_tests subset that passes on node,
  echoServe / HttpServerState / EchoServerClient / uriVarKey cross-runtime
  runners, @TestOn('node') with dart test -p node, and the
  tekartik_build_node tool scripts (nodePackageRunCi).
---

# tekartik_http_node_test: HTTP client conformance on Node.js (tekartik_http_node_test)

`tekartik_http_node_test` has no `lib/`: it is the runnable test package of
the `common_node.dart` repo (`http_node_test`) that runs the shared
`tekartik_http_test` client suites, plus the dart-lang
`http_client_conformance_tests`, against the Node.js clients of
`tekartik_http_node`. Use it as the template for validating any
`HttpClientFactory` under node.

## Guidelines

* Nothing to depend on or import: clone
  `https://github.com/tekartik/common_node.dart`, run `dart pub get` at the
  repo root (a pub workspace) and work inside `http_node_test/`.
  `dart_test.yaml` declares the `node` and `vm` platforms, so `dart test`
  runs both and `dart test -p node` only the node ones. `node` must be on the
  PATH; node tests are compiled with dart2js.
* A similar package of your own needs, as dev dependencies,
  `tekartik_http_node` (git `https://github.com/tekartik/common_node.dart`,
  `path: http_node`), `tekartik_http` and `tekartik_http_test` (git
  `https://github.com/tekartik/http.dart`, `path: http` / `http_test`),
  `tekartik_platform_node`, `test`, and for compiled node scripts
  `build_runner`, `build_web_compilers` and `tekartik_build_node` (git
  `https://github.com/tekartik/build_node.dart`,
  `path: packages/build_node`).
* Client factories under test, all from `tekartik_http_node`:
  `httpClientFactoryNode` (`http_client_node.dart`),
  `httpClientFactoryNodeFetch` (`http_client_node_fetch.dart`) and
  `httpClientFactoryUniversal` (`http_client_universal.dart`, node when
  compiled to JS, `dart:io` on the VM). All three are `HttpClientFactory`
  values with `newClient()`; accessing them off their platform throws
  `UnimplementedError`, so a `vm || node` test must catch it (see the API
  guard example).
* Shared suite: `runEchoServerClientTests(httpClientFactory)` from
  `package:tekartik_http_test/echo_server_client_test.dart` starts its own
  echo server (spawned in the VM even from a node test) and exercises the
  client against it. This is the one call a new client implementation must
  pass. `run(httpFactory)` from `package:tekartik_http_test/http_test.dart`
  is the full client+server suite — on node only `httpFactoryMemory` can run
  it, because `tekartik_http_node` has no server.
* Conformance: `package:http_client_conformance_tests` (git
  `https://github.com/dart-lang/http`, `ref: master`,
  `path: pkgs/http_client_conformance_tests`) is called function by function
  rather than through its own `testAll`, because the node client does not
  pass everything. Node client limits, expressed as the flags this package
  uses: `canStreamRequestBody: false`, `canWorkInIsolates: false`,
  `supportsFoldedHeaders: false`, `supportsMultipartRequest: false`,
  `canSendCookieHeaders: false`, `canReceiveSetCookieHeaders: false`,
  `redirectAlwaysAllowed: true`, `preservesMethodCase: true`; and
  `testRequestMethods` / `testResponseHeaders` are skipped entirely.
* Cross-runtime check: `echoServe(httpServerFactoryIo, 0)` from
  `package:tekartik_http_test/test_server.dart` binds a real `dart:io` echo
  server on a free port and returns an `HttpServerState` (`uri`, `close()`).
  Pass `state.uri` to a child process through the environment variable named
  by `uriVarKey`
  (`package:tekartik_http_test/test_server_client_test.dart`), then run the
  same runner file with `dart test -p vm` and `dart test -p node` via
  `package:process_run`'s `Shell`. The runner reads the variable with
  `platform.environment` from
  `package:tekartik_platform_node/context_universal.dart` (which works on
  both), builds an `EchoServerClient(factory: ..., uri: ...)` and calls
  `run(client)` from `test_server_client_test.dart`. Name the runner
  `*_runner.dart`, not `*_test.dart`, so `dart test` does not pick it up on
  its own. Guard the node half with `isNodeSupportedSync`
  (`package:dev_build/build_support.dart`).
* `build.yaml` sends `node/**` through the `build_web_compilers|entrypoint`
  builder with `compiler: dart2js`; `tool/run_ci.dart` calls
  `nodePackageRunCi('.')` from `package:tekartik_build_node/package.dart`,
  and the other `tool/run_node_*.dart` scripts are one-liners running
  `dart test -p node [-N "<name>"] <file>` through `Shell`.
* Anti-patterns: expecting a server from `tekartik_http_node` (client only,
  use `httpServerFactoryIo` on the VM or `httpFactoryMemory`); running the
  node suites without `node` on the PATH; putting the cross-runtime runner in
  a `_test.dart` file; asserting on cookies, multipart or request streaming
  for the node client.

## Examples

### The node client suites (fetch and default)

```dart
@TestOn('node')
library;

import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_node/http_client_node_fetch.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:test/test.dart';

void main() {
  group('node', () {
    runEchoServerClientTests(httpClientFactoryNode);
  });
  group('node_fetch', () {
    runEchoServerClientTests(httpClientFactoryNodeFetch);
  });
}
```

### Memory factory on node, and the API guard on vm or node

```dart
@TestOn('vm || node')
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_test/http_test.dart' as http_test;
import 'package:test/test.dart';

Future<void> main() async {
  // The full client + server suite: only the memory factory can serve.
  group('memory', () {
    http_test.run(httpFactoryMemory);
  });

  test('httpClientFactoryNode', () {
    try {
      httpClientFactoryNode;
      // Reached only when compiled to javascript.
      expect(isRunningAsJavascript, isTrue);
    } on UnimplementedError catch (_) {}
  });
}
```

### The conformance subset that passes on node

```dart
@TestOn('node')
library;

import 'package:http_client_conformance_tests/http_client_conformance_tests.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:test/test.dart';

Client newClient() => httpClientFactoryNode.newClient();

void main() {
  group('client conformance tests', () {
    testRequestBody(newClient);
    testRequestBodyStreamed(newClient, canStreamRequestBody: false);
    testResponseBody(newClient);
    testResponseBodyStreamed(newClient);
    testRequestHeaders(newClient);
    testResponseStatusLine(newClient);
    testRedirect(newClient, redirectAlwaysAllowed: true);
    testServerErrors(newClient);
    testCompressedResponseBody(newClient);
    testMultipleClients(newClient);
    testMultipartRequests(newClient, supportsMultipartRequest: false);
    testClose(newClient);
    testIsolate(newClient, canWorkInIsolates: false);
    // testRequestMethods / testResponseHeaders currently fail on node.
  });
}
```

### Cross-runtime runner: one io echo server, vm and node clients

```dart
// test/test_client_only_universal_runner.dart -- NOT a _test.dart file.
import 'package:tekartik_http_node/http_client_universal.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var uri = platform.environment[uriVarKey];
  group('echo client', () {
    if (uri != null) {
      run(
        EchoServerClient(
          factory: httpClientFactoryUniversal,
          uri: Uri.parse(uri),
        ),
      );
    }
  }, skip: uri == null ? 'skipped for no uri' : false);
}
```

### Driving that runner from a vm test

```dart
@TestOn('vm')
library;

import 'package:dev_build/build_support.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  late HttpServerState echoServeState;
  setUpAll(() async {
    echoServeState = await echoServe(httpServerFactoryIo, 0);
  });
  tearDownAll(() async {
    await echoServeState.close();
  });

  Future<void> runOn(String platformName) async {
    var shell = Shell(
      environment: ShellEnvironment()
        ..vars[uriVarKey] = echoServeState.uri.toString(),
    );
    await shell.run(
      'dart test -p $platformName test/test_client_only_universal_runner.dart',
    );
  }

  test('vm', () => runOn('vm'));
  test('node', () async {
    if (isNodeSupportedSync) {
      await runOn('node');
    }
  });
}
```

## Common mistakes

* Calling `run(httpFactoryNode)`: there is no node `HttpFactory`, the node
  package is client only — use `runEchoServerClientTests`.
* Touching `httpClientFactoryNode` in a `vm || node` test without catching
  `UnimplementedError`.
* Using `http_client_conformance_tests`' own `testAll`: several of its
  suites fail on node, call the individual `test*` functions instead.
* Naming the cross-runtime runner `*_test.dart`, which makes `dart test`
  run it without the server uri in the environment.
* Running the node tests without `node` on the PATH, or forgetting that they
  go through dart2js so a compile error shows up only at `dart test` time.

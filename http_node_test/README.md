# tekartik_http_node_test

Runs the HTTP client suites against the Node.js clients of
[tekartik_http_node](../http_node/README.md): the shared `tekartik_http_test`
echo server suite, the dart-lang `http_client_conformance_tests` subset that
passes on node, the memory `HttpFactory` suite on node, and a cross-runtime
check (one `dart:io` echo server, the universal client on the VM and on
node). A test package, not a dependency.

## Running

From this folder, with node on the `PATH` (`dart_test.yaml` lists the node
and vm platforms):

```bash
dart test           # node and vm
dart test -p node   # node only
```

* `test/http_node_client_test.dart`, `test/http_node_fetch_client_test.dart`:
  `runEchoServerClientTests` on `httpClientFactoryNode` and
  `httpClientFactoryNodeFetch`.
* `test/http_node_client_conformance_test.dart`: the conformance functions
  the node client passes (no request streaming, cookies, multipart or
  isolates; `testRequestMethods` and `testResponseHeaders` are not run).
* `test/http_memory_test.dart`: `run(httpFactoryMemory)` on node.
* `test/test_client_universal_interop_test.dart` (vm): starts an echo
  server and runs `test/test_client_only_universal_runner.dart` with
  `dart test -p vm` and `-p node` in sub processes (the server url in the
  environment).
* `test/http_node_api_test.dart`: `httpClientFactoryNode` is only available
  when compiled to JavaScript.

`tool/run_ci.dart` runs the package CI (`nodePackageRunCi`).

## Known local failure

`response status line complete` (conformance) can fail locally with an
empty reason phrase instead of `Created` (seen with node 24 under
`dart test -p node`); it passes on the CI runners and with plain node.

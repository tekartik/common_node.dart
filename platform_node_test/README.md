# tekartik_platform_node_test

Tests of [tekartik_platform_node](../platform_node) on the Dart VM, Node.js
(dart2js) and Chrome: which `PlatformContext` is picked on each runtime, the
`Random.secure()` fix of node, and a dart2js-compiled `node/main.dart` that
prints the detected context. Nothing to depend on.

## Running

From a clone of `https://github.com/tekartik/common_node.dart` (a pub
workspace: `dart pub get` at the root):

```bash
cd platform_node_test
dart test                 # vm, node and chrome (dart_test.yaml)
dart test -p node         # node only (node on the PATH)
dart run tool/build_and_run.dart   # compile node/main.dart, run it on node
```

`node/main.dart` (through tekartik_platform_test's example) prints the whole
environment: do not run it where the output is shared.

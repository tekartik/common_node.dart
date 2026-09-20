---
name: tekartik-stdio-node-test-setup
description: >-
  Use when testing or demonstrating tekartik_stdio_node (readline prompts and
  process on Node.js) with tekartik_stdio_node_test: the multiplatform
  process access test, the @TestOn('node') interop test over jsProcess /
  jsStdin / jsStdout / jsReadlineModule.createInterface from
  src/stdio_node_interop.dart, an interactive bin/main.dart using
  readline.question and process.exit, a raw dart:js_interop node script with
  tekartik_js_utils_interop (jsAnyDebugRuntimeType, keys,
  getOwnPropertyNames), and the tekartik_app_node_build tool scripts
  (NodeAppBuilder, NodeAppOptions, NodeAppRunOptions, compileAndRun) that
  compile with dart2js and pipe stdin into node.
---

# tekartik_stdio_node_test: stdin/stdout on Node.js, tested (tekartik_stdio_node_test)

`tekartik_stdio_node_test` has no `lib/`: it is the runnable test and demo
package of the `common_node.dart` repo (`stdio_node_test`) for
`tekartik_stdio_node`. It holds the two automatable tests (what can be
checked without a terminal), an interactive `bin/main.dart`, a raw
`dart:js_interop` variant, and the tool scripts that compile them with
dart2js and run them under node with a real stdin.

## Guidelines

* Nothing to depend on or import: clone
  `https://github.com/tekartik/common_node.dart`, run `dart pub get` at the
  repo root (a pub workspace) and work inside `stdio_node_test/`.
  `dart_test.yaml` declares the `node` and `vm` platforms with
  `concurrency: 1`; `dart test` runs both, `dart test -p node` needs `node`
  on the PATH and goes through dart2js.
* A similar package of your own needs `tekartik_stdio_node` (git
  `https://github.com/tekartik/common_node.dart`, `path: stdio_node`),
  `tekartik_platform_node` (same repo, `path: platform_node`),
  `tekartik_js_utils_interop` (git
  `https://github.com/tekartik/js_utils.dart`, `path: js_utils_interop`) for
  raw interop, and as dev dependencies `test`, `process_run`,
  `build_runner`, `build_web_compilers`, `tekartik_build_node` (git
  `https://github.com/tekartik/build_node.dart`, `path: packages/build_node`)
  and `tekartik_app_node_build` (git
  `https://github.com/tekartik/app_node_utils.dart`, `path: app_build`).
* **What can and cannot be tested.** `readline.question(prompt)` blocks on a
  real terminal, so it cannot run under `dart test`: no test in this package
  calls it. Keep prompt calls in the entry point (`bin/main.dart` or a
  `node/` script) and test only (a) that `process`
  (`package:tekartik_stdio_node/process.dart`) is reachable on every
  platform, and (b) under `@TestOn('node')`, that the raw interop objects
  (`jsProcess`, `jsProcess.stdin`, `jsProcess.stdout`) are there. Logic that
  consumes answers should take a `Readline` (the abstract class from
  `readline.dart`) so a test can inject scripted answers.
* Test layout: `test/multiplatform/*.dart` for files with no `@TestOn` that
  must pass on vm **and** node, `test/node/*.dart` for `@TestOn('node')`
  files. The node interop test imports
  `package:tekartik_stdio_node/src/stdio_node_interop.dart` — that is a
  `src/` library, acceptable only because this package tests the
  implementation; application code must stay on `readline.dart` and
  `process.dart`.
* Interop surface re-exported by `src/stdio_node_interop.dart`: `jsProcess`,
  `jsStdin`, `jsStdout`, `jsProcessModule`, `JsProcessStdio`,
  `jsReadlineModule`, `JsReadlineModule`, `JsReadlineModuleExt`
  (`createInterface(input, output)`), `JsReadline` (`question(query)`
  returning a `JSPromise<JSAny>`, `close()`) and
  `JsReadlineInterfaceOptions`. Use `.toDart` on the promise, then
  `tekartik_js_utils_interop` to inspect the result: `jsAnyDebugRuntimeType`,
  `jsAnyToDebugString` (`js_converter.dart`), `keys()` /
  `getOwnPropertyNames()` (`object_keys.dart`, `JSObjectKeysExtension`).
* Ending an interactive node program: the readline interface keeps stdin
  open, so `rl.close()` alone does not let node exit — finish with
  `process.exit(0)`. The same `main` then works on the VM too.
* `build.yaml` compiles `node/**` with `build_web_compilers|entrypoint` and
  `compiler: dart2js`. To *run* an interactive script you need stdin piped
  into the spawned node process, which is what
  `NodeAppBuilder(options: NodeAppOptions(srcDir: 'bin', srcFile:
  'main.dart')).compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin))`
  does (`package:tekartik_app_node_build/app_build.dart`): it compiles with
  `nodePackageCompileJs`, copies to `deploy/` and runs node with the parent
  `dart:io` `stdin` attached. `NodeAppOptions` defaults: `packageTop: '.'`,
  `deployDir: 'deploy'`, `srcDir: 'bin'`, `srcFile: 'main.dart'`.
* Anti-patterns: calling `readline.question` from a test (it hangs);
  importing `tekartik_stdio_node/src/...` from application code; expecting
  `dart run bin/main.dart` compiled output to exit without `process.exit`;
  running the node tests with `-j` above 1 (`dart_test.yaml` sets
  `concurrency: 1`).

## Examples

### Multiplatform test: process is reachable on vm and node

```dart
library;

import 'package:tekartik_stdio_node/process.dart';
import 'package:test/test.dart';

void main() {
  group('process', () {
    test('access', () {
      expect(process, isNotNull);
    });
  });
}
```

### Node-only interop test

```dart
// ignore_for_file: avoid_print

@TestOn('node')
library;

import 'package:tekartik_stdio_node/src/stdio_node_interop.dart';
import 'package:test/test.dart';

void main() {
  group('stdio_node_interop', () {
    test('out', () {
      print('jsProcess: $jsProcess');
      print('stdin: ${jsProcess.stdin}');
      print('stdout: ${jsProcess.stdout}');
      expect(jsStdin, isNotNull);
      expect(jsStdout, isNotNull);
    });
  });
}
```

### Interactive entry point (bin/main.dart)

```dart
// ignore_for_file: avoid_print

import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

Future<void> main() async {
  print('hello');
  var rl = readline;
  var answer = await rl.question('What do you think of Node.js? ');
  print('answer: $answer');
  rl.close();
  print('closed');
  // Needed on node: the readline interface keeps stdin open.
  process.exit(0);
}
```

### Same prompt through the raw js_interop layer (node/raw_node.dart)

```dart
// ignore_for_file: avoid_print

import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_stdio_node/src/stdio_node_interop.dart';

Future<void> main() async {
  print('hello');
  var rl = jsReadlineModule.createInterface(jsStdin, jsStdout);
  var answer = await rl.question('What do you think of Node.js? ').toDart;
  print(answer.keys());
  print(answer.getOwnPropertyNames());
  print(jsAnyDebugRuntimeType(answer));
  print('answer: $answer');
  rl.close();
}
```

### Tool scripts: compile with dart2js and run under node with stdin

```dart
import 'dart:io';

import 'package:tekartik_app_node_build/app_build.dart';

/// tool/build_and_run_node.dart -- compiles bin/main.dart, runs it on node.
Future<void> main() async {
  var builder = NodeAppBuilder(
    options: NodeAppOptions(srcDir: 'bin', srcFile: 'main.dart'),
  );
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}

/// tool/build_and_run_raw_node.dart -- same for the raw interop variant.
Future<void> buildAndRunRaw() async {
  var builder = NodeAppBuilder(
    options: NodeAppOptions(srcDir: 'node', srcFile: 'raw_node.dart'),
  );
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}
```

## Common mistakes

* Writing a `dart test` case around `readline.question`: there is no
  terminal, it never returns. Test the surrounding logic with an injected
  `Readline` instead.
* Forgetting `process.exit(0)` at the end of an interactive node program.
* Reaching for `package:tekartik_stdio_node/src/stdio_node_interop.dart`
  outside this test package; `readline.dart` and `process.dart` are the
  public API.
* Running an interactive compiled script with plain `node deploy/main.js`
  from a tool script without forwarding stdin — use
  `NodeAppRunOptions(stdin: stdin)`.
* Dropping `concurrency: 1` from `dart_test.yaml`: the vm and node runs
  share the `build/` and `deploy/` output.

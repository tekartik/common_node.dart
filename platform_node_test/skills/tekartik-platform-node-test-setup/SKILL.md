---
name: tekartik-platform-node-test-setup
description: >-
  Use when testing the PlatformContext implementations across node, the Dart
  VM and the browser with tekartik_platform_node_test: platformContextNode,
  platformContextIo, platformContextBrowser and platformContextUniversal,
  the isRunningInNode / isRunningInNodeOrIo / isRunningAsJavascript /
  kDartIsWeb guards, nodeVersion, context.platform / io / node / browser and
  context.toMap(), the tekartik_platform_test platform_context_example run()
  dump, @TestOn('node') with dart test -p node,vm,chrome, and the
  tekartik_build_node tool scripts (nodePackageCompileJs, nodePackageRun,
  nodePackageRunCi).
---

# tekartik_platform_node_test: PlatformContext tests on node, vm and browser (tekartik_platform_node_test)

`tekartik_platform_node_test` has no `lib/`: it is the runnable test package
of the `common_node.dart` repo (`platform_node_test`) that checks
`tekartik_platform_node` against `tekartik_platform_io` and
`tekartik_platform_browser` on all three runtimes, plus a dart2js-compiled
`node/main.dart` that dumps the detected context. Use it as the template for
any code that must behave the same on the VM, on node and in a browser.

## Guidelines

* Nothing to depend on or import: clone
  `https://github.com/tekartik/common_node.dart`, run `dart pub get` at the
  repo root (a pub workspace) and work inside `platform_node_test/`.
  `dart_test.yaml` declares the `node`, `vm` and `chrome` platforms, so plain
  `dart test` runs all three; `dart test -p node` (needs `node` on the PATH,
  compiled with dart2js) or `-p chrome` narrows it.
* A similar package of your own needs `tekartik_platform`,
  `tekartik_platform_io`, `tekartik_platform_browser` (git
  `https://github.com/tekartik/platform.dart`, `path: platform` /
  `platform_io` / `platform_browser`), `tekartik_platform_node` (git
  `https://github.com/tekartik/common_node.dart`, `path: platform_node`),
  `tekartik_platform_test` (`path: platform_test`), `tekartik_common_utils`,
  `test`, and for the compiled node script `build_runner` and
  `tekartik_build_node` (git `https://github.com/tekartik/build_node.dart`,
  `path: packages/build_node`).
* The contexts, one import each:
  `platformContextNode` (`tekartik_platform_node/context_node.dart`),
  `platformContextIo` (`tekartik_platform_io/context_io.dart`),
  `platformContextBrowser` (`tekartik_platform_browser/context_browser.dart`)
  and `platformContextUniversal` plus `platform` / `platformUniversal`
  (`tekartik_platform_node/context_universal.dart`, which resolves to node
  when compiled to JavaScript and to io otherwise).
* Every `PlatformContext` exposes the nullable `browser`, `platform`, `io`,
  `node` and a `toMap()` for debugging. Which one is non-null is the whole
  point of the suite: `io` on the VM, `node` under node, `browser` in a
  browser; `platform` (with `isWindows` / `isMacOS` / `isLinux` and
  `environment`) is non-null for io and node but null in a browser.
  `nodeVersion` is only meaningful when `context.node != null`.
* Runtime guards, and which one to use:
  - `isRunningInNode` (`context_node.dart`) — true only under node.
  - `isRunningInNodeOrIo` (`context_node.dart`) — false only in a browser;
    this is the guard that picks `platformContextUniversal` versus
    `platformContextBrowser` in a test with no `@TestOn`.
  - `isRunningAsJavascript` and `kDartIsWeb`
    (`tekartik_common_utils/env_utils.dart`) — `kDartIsWeb && !isRunningInNode`
    is "real browser", `!kDartIsWeb` is "VM".
  Do not gate on `@TestOn` alone: a library-level `library;` file with no
  `@TestOn` must compile and pass on all three platforms.
* Accessing the wrong context for the runtime throws `UnimplementedError`
  (importing it is always safe). A multiplatform API test therefore wraps
  each access in `try { platformContextIo; expect(...); } on
  UnimplementedError catch (_) {}` and asserts the matching
  `isRunningAsJavascript` value in the branch that succeeded.
* Shared dump: `run(context)` from
  `package:tekartik_platform_test/platform_context_example.dart` prints every
  detected flag (`io.isAndroid`, `platform.isLinux`, `browser.isChrome`,
  `browser.os.isMac`, `browser.device.isIPad`, `browser.version`, …).
  That library hides `dart:core`'s `print` and exposes a
  `late void Function(Object?) print` you must assign before calling `run`.
* Compiled node script: `node/main.dart` prints
  `JsonEncoder.withIndent('  ').convert(context.toMap())` and calls the
  shared dump; platform-specific extras live in
  `node/platform_io.dart` / `node/platform_node.dart` selected with
  `import 'platform_io.dart' if (dart.library.js_interop)
  'platform_node.dart';`. `build.yaml` compiles `node/**` with
  `build_web_compilers|entrypoint` and `compiler: dart2js`;
  `tool/build_and_run.dart` runs `nodePackageCompileJs('.', input:
  'node/main.dart')` then `nodePackageRun('.')`
  (`package:tekartik_build_node/build_node.dart`), and `tool/run_ci.dart`
  runs `nodePackageRunCi('.')` (`package:tekartik_build_node/package.dart`).
* Anti-patterns: importing `tekartik_platform_node/src/...` (only
  `node/platform_node.dart` does, to reach the raw node `Platform` interop
  for a debug dump); asserting `context.platform` is non-null in a chrome
  test; assuming `isRunningAsJavascript` means browser (it is also true under
  node, and false under wasm).

## Examples

### Multiplatform API test: every context, no @TestOn

```dart
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_browser/context_browser.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

void main() {
  group('context_node_api', () {
    test('multiplatform', () {
      // Never throws: io on the vm, node when compiled to javascript.
      expect(platformContextUniversal, isNotNull);
    });
    test('io', () {
      try {
        platformContextIo;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}
    });
    test('node', () {
      try {
        platformContextNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
    test('browser or not', () {
      var context = isRunningInNodeOrIo
          ? platformContextUniversal
          : platformContextBrowser;
      expect(context.toMap(), isNotEmpty);
    });
  });
}
```

### Asserting which context wins on each runtime

```dart
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_browser/context_browser.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

final platformContext = isRunningInNodeOrIo
    ? platformContextUniversal
    : platformContextBrowser;

void main() {
  var isNodeEnv = isRunningInNode;
  var isBrowserEnv = kDartIsWeb && !isRunningInNode;

  test('platformContext', () {
    if (isNodeEnv) {
      expect(platformContext, platformContextNode);
      expect(platformContext.node, isNotNull);
      expect(platformContext.platform!.environment, isNotNull);
      expect(nodeVersion, isNotNull);
    } else if (isBrowserEnv) {
      expect(platformContext, platformContextBrowser);
      expect(platformContext.browser, isNotNull);
      expect(platformContext.platform, isNull);
    } else {
      expect(platformContext, platformContextIo);
      expect(platformContext.io, isNotNull);
      expect(platformContext.platform!.environment, isNotNull);
    }
  });
}
```

### Node-only assertions

```dart
@TestOn('node')
library;

import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('node', () {
    test('info', () {
      var node = platformContextNode.node!;
      expect(node.environment, isNotNull);
      expect(node.isLinux || node.isMacOS || node.isWindows, isTrue);
      expect(nodeVersion, isNotNull);
    });
  });
}
```

### The compiled node/main.dart dump

```dart
import 'dart:convert';

import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:tekartik_platform_test/platform_context_example.dart' as common;

void main() {
  run(platformContextUniversal);
}

void run(PlatformContext context) {
  // ignore: avoid_print
  print(const JsonEncoder.withIndent('  ').convert(context.toMap()));

  // The shared dump hides dart:core's print, assign it first.
  common.print = print;
  common.run(context);
  if (context.node != null) {
    // ignore: avoid_print
    print('nodeVersion: $nodeVersion');
  }
}
```

### Tool scripts: compile and run on node, run CI

```dart
import 'package:process_run/shell_run.dart';
import 'package:tekartik_build_node/build_node.dart';
import 'package:tekartik_build_node/package.dart';

/// tool/build_and_run.dart
Future<void> buildAndRun() async {
  await nodePackageCompileJs('.', input: 'node/main.dart');
  await nodePackageRun('.');
}

/// tool/run_node_test.dart
Future<void> runNodeTests() async {
  await run('dart test -p node -r expanded');
}

/// tool/run_ci.dart: format check, analyze, then the vm/node/chrome tests
Future<void> main() async {
  await nodePackageRunCi('.');
}
```

## Common mistakes

* Expecting `platformContext.platform` (and therefore `environment`) to be
  non-null in a chrome test: only `browser` is set there.
* Reading `platformContextNode` or `platformContextIo` without the
  `UnimplementedError` guard in a test that also runs elsewhere.
* Treating `isRunningAsJavascript` as "browser": node is JavaScript too, and
  wasm is web but not JavaScript.
* Calling `common.run(context)` from
  `tekartik_platform_test/platform_context_example.dart` without assigning
  `common.print` first (it is a `late` field and throws otherwise).
* Running the node platform tests without `node` on the PATH.

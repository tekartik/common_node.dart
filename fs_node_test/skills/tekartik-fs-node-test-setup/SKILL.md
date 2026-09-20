---
name: tekartik-fs-node-test-setup
description: >-
  Use when running or extending the fs_shim conformance suite against the
  Node.js file system implementation (tekartik_fs_node fileSystemNode) with
  tekartik_fs_node_test: building a FileSystemTestContext with
  FileSystemTestContextMixin and a PlatformContextIo subclass (isIoNode)
  from tekartik_fs_test, calling defineTests / defineFsTests, sandboxed
  contexts (ctx.sandbox(path:)), memoryFileSystemTestContext on node,
  @TestOn('node') with dart test -p node, dart_test.yaml platforms, and the
  tekartik_build_node tool scripts (nodePackageRunCi, nodePackageCompileJs,
  nodePackageRun).
---

# tekartik_fs_node_test: fs_shim conformance suite on Node.js (tekartik_fs_node_test)

`tekartik_fs_node_test` has no `lib/`: it is the runnable test package of
the `common_node.dart` repo (`fs_node_test`) that runs `tekartik_fs_test`'s
shared `FileSystem` suite against `fileSystemNode` from `tekartik_fs_node`,
raw and sandboxed, plus the memory file system compiled with dart2js. Use it
as the template for testing any `FileSystem` implementation under node.

## Guidelines

* Nothing to depend on or import: clone
  `https://github.com/tekartik/common_node.dart`, run `dart pub get` at the
  repo root (a pub workspace) and work inside `fs_node_test/`. `dart test`
  runs the `dart_test.yaml` platforms (`node` and `vm`, `concurrency: 1`);
  `dart test -p node` runs only the node ones. `node` must be on the PATH,
  tests are compiled with dart2js.
* A similar package of your own needs the dev dependencies
  `tekartik_fs_test` (git `https://github.com/tekartik/fs_shim.dart`,
  `path: fs_test`), `tekartik_fs_node` and `tekartik_platform_node` (git
  `https://github.com/tekartik/common_node.dart`, `path: fs_node` /
  `platform_node`), `test`, and for compiled node scripts `build_runner`,
  `build_web_compilers` and `tekartik_build_node` (git
  `https://github.com/tekartik/build_node.dart`,
  `path: packages/build_node`).
* Context object: `defineTests(FileSystemTestContext ctx)` (alias of
  `defineFsTests`) from `package:tekartik_fs_test/fs_test.dart` needs a
  `FileSystemTestContext`. Implement it with `FileSystemTestContextMixin`
  (exported by `fs_test.dart` and `test_common.dart`), providing `fs` (the
  `FileSystem` under test), `platform` (a `PlatformContext` from
  `package:tekartik_fs_test/test_common.dart`) and `basePath` (root of the
  generated files, keep it under `.dart_tool/`). The mixin supplies `path`,
  `baseDir`, `prepare()` (recreates the per-test directory) and
  `supportsFileContentStream` (`true`).
* Platform flags: the suite adapts through `ctx.platform`. Subclass
  `PlatformContextIo` (`test_common.dart`), override `isIoNode` to `true`
  and set `isIoWindows` / `isIoMacOS` / `isIoLinux` from
  `platformContextNode.node` (`tekartik_platform_node/context_node.dart`);
  the suite's `isIoNode(ctx)`, `isIoWindows(ctx)` ... helpers use them to
  skip io-only expectations (windows rename semantics for instance).
* Sandbox: `ctx.sandbox(path: ...)` (extension on `FileSystemTestContext`)
  wraps `ctx.fs.sandbox(path:)` so the whole suite runs under one root; the
  package runs the suite raw (`test/node/fs_node_test.dart`) and sandboxed
  (`test/node/fs_node_sandbox_test.dart`).
* Memory on node: `defineTests(memoryFileSystemTestContext)`
  (`test/multiplatform/fs_memory_test.dart`) checks the memory file system
  compiled with dart2js; `fs` from `tekartik_fs_node/fs_node_universal.dart`
  gives a smoke test running on both `vm` and `node` without `@TestOn`.
* Node capabilities the suite relies on: `fs.name == 'node_io'`,
  `supportsLink`, `supportsFileLink` and `supportsRandomAccess` all `false`;
  the suite skips the corresponding groups by itself.
* Tool scripts (`tool/`): `run_node_tests.dart` and
  `run_memory_node_tests.dart` run `dart test -p node -r expanded -j 1
  <file>` through `process_run`'s `run`; `run_ci.dart` calls
  `nodePackageRunCi('.')` (`package:tekartik_build_node/package.dart`);
  `build_node.dart` (`nodePackageCompileJs('.')`) and `run_node.dart`
  (`nodePackageRun('.')`) from `package:tekartik_build_node/build_node.dart`
  compile and run `node/main.dart`, a script reading `pubspec.yaml` through
  `fileSystemNode`, using the `build.yaml` dart2js target on `node/**`.
* Run one file with `dart test -p node test/node/fs_node_test.dart`, filter
  a test with `-N <name>`, and keep `-j 1`: the suites share output
  directories.

## Examples

### Node test context and the full suite, raw and sandboxed

```dart
@TestOn('node')
library;

import 'package:tekartik_fs_node/fs_node_interop.dart';
import 'package:tekartik_fs_test/fs_test.dart';
import 'package:tekartik_fs_test/test_common.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

class PlatformContextNode extends PlatformContextIo {
  PlatformContextNode() {
    // `this.` needed: isIoWindows(ctx) / isIoLinux(ctx) are also suite helpers
    this.isIoWindows = platformContextNode.node?.isWindows ?? false;
    this.isIoMacOS = platformContextNode.node?.isMacOS ?? false;
    this.isIoLinux = platformContextNode.node?.isLinux ?? false;
  }

  @override
  bool get isIoNode => true;
}

class FileSystemTestContextNode
    with FileSystemTestContextMixin
    implements FileSystemTestContext {
  @override
  final PlatformContext platform = PlatformContextNode();
  @override
  final FileSystem fs = fileSystemNode;

  FileSystemTestContextNode(String path) {
    basePath = fs.path.join('.dart_tool', 'tekartik_fs_node', 'test', path);
  }
}

void main() {
  var ctx = FileSystemTestContextNode('fs_node');
  var fs = ctx.fs;

  group('fs_node', () {
    test('capabilities', () {
      expect(fs.name, 'node_io');
      expect(fs.supportsLink, isFalse);
      expect(fs.supportsFileLink, isFalse);
      expect(fs.supportsRandomAccess, isFalse);
      expect(isIoNode(ctx), isTrue);
    });
    defineTests(ctx);
  });

  group('fs_node_sandbox', () {
    var sandboxPath = ctx.path.join(
      '.dart_tool',
      'tekartik_fs_node',
      'test',
      'node_sandbox',
    );
    defineTests(ctx.sandbox(path: sandboxPath));
  });
}
```

### Memory suite and universal smoke test (vm and node)

```dart
import 'package:tekartik_fs_node/fs_node_universal.dart';
import 'package:tekartik_fs_test/fs_test.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    defineTests(memoryFileSystemTestContext);
  });
  test('universal', () async {
    expect(await fs.file('pubspec.yaml').exists(), isTrue);
    expect(await fs.directory('test').exists(), isTrue);
  });
}
```

### Tool scripts: run the node suite, run CI

```dart
import 'package:process_run/shell_run.dart';
import 'package:tekartik_build_node/package.dart';

/// tool/run_node_tests.dart
Future<void> runNodeTests() async {
  await run('dart test -p node -r expanded -j 1 test/node/fs_node_test.dart');
}

/// tool/run_ci.dart: analyze, format check and node/vm tests
Future<void> main() async {
  await nodePackageRunCi('.');
}
```

### Compiled node script (node/main.dart)

```dart
import 'package:tekartik_fs_node/fs_node.dart';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  var content = await fileSystemNode.file('pubspec.yaml').readAsString();
  var map = loadYaml(content) as Map;
  print('${map['name']} ${map['version']}');
}
```

## Common mistakes

* Running the node suites concurrently (`-j` above 1): they write to the
  same `.dart_tool/tekartik_fs_node/test` tree.
* Forgetting `isIoNode => true` in the platform context: windows-only io
  expectations then fail on node.
* Importing `FileSystemNode` from `tekartik_fs_node/src/...`: type the file
  system as `FileSystem`, the public API is `fileSystemNode`.

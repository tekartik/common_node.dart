---
name: tekartik-fs-node-setup
description: >-
  Use when Dart code compiled for Node.js (dart2js scripts, firebase
  functions, node tools) needs file system access through the fs_shim
  FileSystem API with tekartik_fs_node: fileSystemNode (node:fs/promises
  backend), fileSystemUniversal and its alias fs (node when running as
  JavaScript, fileSystemIo on the Dart VM), the fs_node.dart /
  fs_node_interop.dart / fs_node_universal.dart imports, the node backend
  limits (no links, no random access, name 'node_io'), FileSystemException
  status codes, and testing fs_shim code with dart test -p node.
---

# tekartik_fs_node: fs_shim on Node.js (tekartik_fs_node)

`tekartik_fs_node` implements the `fs_shim` `FileSystem` abstraction on top
of the node `fs` module (`node:fs/promises`, loaded with `require` from
`tekartik_core_node`). Code written against `package:fs_shim/fs.dart` runs
unchanged on the VM (`fileSystemIo`), in memory (`fileSystemMemory`) and on
node (`fileSystemNode`); `fileSystemUniversal` picks node or io at runtime.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_fs_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: fs_node
    fs_shim: '>=2.5.2'
  ```
  Declare `fs_shim` too when importing `package:fs_shim/fs.dart` directly
  in shared code.
* Imports:
  * `package:tekartik_fs_node/fs_node.dart`: re-exports
    `package:fs_shim/fs_shim.dart` (`FileSystem`, `File`, `Directory`,
    `FileMode`, `FileSystemException`, `fileSystemMemory`, ...) and adds
    `fileSystemNode`.
  * `package:tekartik_fs_node/fs_node_interop.dart`: only `fileSystemNode`.
  * `package:tekartik_fs_node/fs_node_universal.dart`: re-exports fs_shim
    and adds `fileSystemUniversal` plus its short alias `fs`:
    `fileSystemNode` when the code runs as JavaScript, `fileSystemIo`
    (`dart:io`) on the VM. Prefer it in code and tests shared between a node
    build and a dart script.
  * `fs_node_legacy.dart` is deprecated (same `fileSystemNode`); do not use
    it in new code.
* `fileSystemNode` is a `FileSystem` created on first access; it requires
  `node:fs/promises` and `node:fs` (for `lstatSync`) at that moment, so
  touching it on the VM or in a browser throws. Keep node-only code behind
  `isRunningInNode` (`tekartik_platform_node/context_node.dart`) or use
  `fileSystemUniversal`.
* Capabilities: `fs.name` is `'node_io'`; `supportsLink`, `supportsFileLink`
  and `supportsRandomAccess` are `false` (no `Link` objects, no random
  access files). `fs.path` is `package:path`'s host `context` (`\` on
  windows like the VM), `fs.currentDirectory` is the node `process.cwd()`
  and relative paths resolve against it.
* Supported operations: `File` `create` (parent must exist unless
  `recursive: true`), `exists`, `stat` (`type`, `size`, `mode`,
  `modified`), `readAsBytes` / `readAsString`, `writeAsBytes` /
  `writeAsString` with `FileMode.write` or `FileMode.append`,
  `openRead([start, end])` (64 KiB chunks), `openWrite(mode:)` (a
  `FileStreamSink`, `close()` flushes), `copy`, `rename`, `delete`;
  `Directory` `create(recursive:)`, `list(recursive:)` (files and
  directories only, symbolic links are skipped), `rename`,
  `delete(recursive:)`; `fs.type(path)` and `fs.directory(path).exists()`.
* Errors surface as `FileSystemException` (a `FileSystemExceptionNode`) with
  `status` normalized to the fs_shim constants on linux, macOS and windows:
  `FileSystemException.statusNotFound`, `statusAlreadyExists`,
  `statusNotADirectory`, `statusIsADirectory`, `statusNotEmpty`. Branch on
  `e.status`, never on `e.message` (the raw node text).
* Windows: renaming over an existing entity is rejected before calling node
  (node itself would sometimes succeed), so the behaviour matches the VM.
* Running on node: compile the entry point with dart2js
  (`dart compile js -o build/main.js node/main.dart`, then
  `node build/main.js`); the repo builds its `node/` scripts with
  `build_runner` + `build_web_compilers` and `tekartik_build_node`.
* Tests: `@TestOn('node')` tests run with `dart test -p node` (node on the
  PATH); tests written against `fileSystemUniversal` and tagged
  `@TestOn('vm || node')` run with `dart test -p vm,node`. Write test files
  under `.dart_tool/`. The fs_shim conformance suite (`defineTests` from
  `tekartik_fs_test`) is run against `fileSystemNode` by the sibling package
  `tekartik_fs_node_test` (`fs_node_test` in the same repo).

## Examples

### Node script reading a file

```dart
import 'package:tekartik_fs_node/fs_node.dart';

Future<void> main() async {
  var fs = fileSystemNode;
  var content = await fs.file('pubspec.yaml').readAsString();
  print(content.split('\n').first);
}
```

### Same code on node and on the VM

```dart
import 'package:tekartik_fs_node/fs_node_universal.dart';

Future<void> main() async {
  var dir = fs.directory(fs.path.join('.dart_tool', 'fs_node_demo'));
  await dir.create(recursive: true);
  var file = fs.file(fs.path.join(dir.path, 'hello.txt'));
  await file.writeAsString('hello\n');
  await file.writeAsString('world\n', mode: FileMode.append);
  print(await file.readAsString());
  await for (var entity in dir.list()) {
    print('${entity is Directory ? 'dir ' : 'file'} ${entity.path}');
  }
  await dir.delete(recursive: true);
}
```

### Streaming copy and error status

```dart
import 'package:tekartik_fs_node/fs_node_universal.dart';

Future<void> copyFile(String from, String to) async {
  var sink = fs.file(to).openWrite();
  await sink.addStream(fs.file(from).openRead());
  await sink.close();
}

Future<String?> readOrNull(String path) async {
  try {
    return await fs.file(path).readAsString();
  } on FileSystemException catch (e) {
    if (e.status == FileSystemException.statusNotFound) {
      return null;
    }
    rethrow;
  }
}
```

### Shared test for vm and node

```dart
@TestOn('vm || node')
library;

import 'package:tekartik_fs_node/fs_node_universal.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

void main() {
  test('write and read', () async {
    var file = fs.file(fs.path.join('.dart_tool', 'fs_node_demo', 'test.txt'));
    await file.parent.create(recursive: true);
    await file.writeAsString('content');
    expect(await file.readAsString(), 'content');
    expect(fs.path.separator, platform.isWindows ? r'\' : '/');
  });
}
```

## Common mistakes

* Reading `fileSystemNode` from code that also runs on the VM: use `fs`
  from `fs_node_universal.dart`.
* Expecting `fs.link(...)` or random access support on node.
* Matching on the exception message instead of `FileSystemException.status`.

# tekartik_fs_node

The [fs_shim](https://pub.dev/packages/fs_shim) `FileSystem` API on Node.js
(Dart compiled to JavaScript with dart2js), on top of `node:fs/promises`.
Code written against `package:fs_shim/fs.dart` runs unchanged on node
(`fileSystemNode`), on the Dart VM (`fileSystemIo`) and in memory.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_fs_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: fs_node
```

```dart
import 'package:tekartik_fs_node/fs_node_universal.dart';

Future<void> main() async {
  // fileSystemNode on node, fileSystemIo on the Dart VM.
  var dir = fs.directory(fs.path.join('.dart_tool', 'fs_node_demo'));
  await dir.create(recursive: true);
  var file = fs.file(fs.path.join(dir.path, 'hello.txt'));
  await file.writeAsString('hello');
  print(await file.readAsString());
  await dir.delete(recursive: true);
}
```

Run it on the VM with `dart run`, on node in a test (`dart test -p node`) or
after a dart2js build with the node preamble
([tekartik_build_node](https://github.com/tekartik/build_node.dart)).

## Libraries and platforms

* `package:tekartik_fs_node/fs_node.dart`: fs_shim plus `fileSystemNode`
  (node only: reading it on the VM or in a browser fails).
* `package:tekartik_fs_node/fs_node_universal.dart`: fs_shim plus
  `fileSystemUniversal` and its alias `fs`: node when compiled to
  JavaScript, `fileSystemIo` on the VM.
* `package:tekartik_fs_node/fs_node_interop.dart`: `fileSystemNode` only.

## What is supported

Files (create, read, write, append, `openRead`, `openWrite`, copy, rename,
delete, stat) and directories (create, list, rename, delete). No links
(`supportsLink` false, links are skipped by `list`), no random access files.
Errors are `FileSystemException`s whose `status` uses the fs_shim constants
(`statusNotFound`, `statusAlreadyExists`, `statusIsADirectory`,
`statusNotADirectory`, `statusNotEmpty`) on linux, macOS and windows. The
behaviour follows `dart:io` and is checked by the fs_shim conformance suite
(`fs_node_test` in this repository).

## Common pitfalls

* Branch on `e.status`, not on the message (the raw node text).
* `fileSystemNode` is node only: use `fs` / `fileSystemUniversal` in code
  shared with the VM.
* As `dart:io`, deleting a missing file or directory fails (status
  `statusNotFound`), even with `recursive: true`.

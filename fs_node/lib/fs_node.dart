/// fs_shim on Node.js: re-exports `package:fs_shim/fs_shim.dart` and adds
/// [fileSystemNode] (node only).
///
/// Use `package:tekartik_fs_node/fs_node_universal.dart` in code shared with
/// the Dart VM.
library;

export 'package:fs_shim/fs_shim.dart';
export 'fs_node_interop.dart';

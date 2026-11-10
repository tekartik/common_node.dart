/// fs_shim on Node.js and the Dart VM: re-exports
/// `package:fs_shim/fs_shim.dart` and adds [fileSystemUniversal] and its
/// alias [fs].
library;

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/universal/universal.dart';

export 'package:fs_shim/fs_shim.dart';
export 'package:tekartik_fs_node/src/universal/universal.dart'
    show fileSystemUniversal;

/// The node file system when compiled to JavaScript, `fileSystemIo` on the
/// Dart VM.
FileSystem get fs => fileSystemUniversal;

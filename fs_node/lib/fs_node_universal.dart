import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/universal/universal.dart';
export 'package:tekartik_fs_node/src/universal/universal.dart'
    show fileSystemUniversal;

/// Work on node & io
FileSystem get fs => fileSystemUniversal;

import 'package:fs_shim/fs_io.dart';
import 'package:tekartik_fs_node/fs_node_interop.dart';

/// Global universal file system instance.
FileSystem get fileSystemUniversal => fileSystemNode;

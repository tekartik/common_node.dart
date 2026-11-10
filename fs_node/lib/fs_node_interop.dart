/// [fileSystemNode] only, the fs_shim file system of Node.js.
library;

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/node/fs_node.dart' as fs_node;

/// The Node.js file system (`node:fs/promises`), node only.
FileSystem get fileSystemNode => fs_node.fileSystemNode;

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/node/fs_node.dart' as fs_node;

@Deprecated('Use fs_node')
FileSystem get fileSystemNode => fs_node.fileSystemNode;

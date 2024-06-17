library fs_shim.test.test_common_io;

// basically same as the io runner but with extra output
import 'package:path/path.dart';
import 'package:tekartik_fs_node/fs_node_interop.dart';
import 'package:tekartik_fs_node/src/node/file_system_node.dart';
import 'package:tekartik_fs_test/test_common.dart';

export 'package:test/test.dart';

class PlatformContextNode extends PlatformContext {}

class FileSystemTestContextNode extends FileSystemTestContext {
  @override
  final PlatformContext platform = PlatformContextNode();
  @override
  final FileSystemNode fs = fileSystemNode as FileSystemNode;

  /// Not supported yet.
  @override
  bool get supportsFileContentStream => false;
  FileSystemTestContextNode(String path) {
    basePath = join('.dart_tool', 'tekartik_fs_node', 'test', path);
  }
}

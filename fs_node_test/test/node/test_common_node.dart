library fs_shim.test.test_common_io;

// basically same as the io runner but with extra output
import 'package:path/path.dart';
import 'package:tekartik_fs_node/fs_node_interop.dart';
import 'package:tekartik_fs_node/src/node/file_system_node.dart';
import 'package:tekartik_fs_test/test_common.dart';
import 'package:tekartik_platform_node/context_node.dart';

export 'package:test/test.dart';

class PlatformContextNode extends PlatformContextIo {
  PlatformContextNode() {
    this.isIoWindows = platformContextNode.node?.isWindows ?? false;
    isIoMacOS = platformContextNode.node?.isMacOS ?? false;
    this.isIoLinux = platformContextNode.node?.isLinux ?? false;
  }
}

class FileSystemTestContextNode extends FileSystemTestContext {
  @override
  final PlatformContext platform = PlatformContextNode();
  @override
  final FileSystemNode fs = fileSystemNode as FileSystemNode;

  /// Not supported yet.
  @override
  bool get supportsFileContentStream => true;
  FileSystemTestContextNode(String path) {
    basePath = join('.dart_tool', 'tekartik_fs_node', 'test', path);
  }
}

@TestOn('node')
library;

import 'package:tekartik_fs_test/fs_test.dart';

import 'test_common_node.dart';

void main() {
  FileSystemTestContext fileSystemContext = FileSystemTestContextNode(
    'fs_node',
  );
  var p = fileSystemContext.path;
  fileSystemContext = fileSystemContext.sandbox(
    path: p.join('.dart_tool', 'tekartik_fs_shim', 'test', 'node_sandbox'),
  );
  group('node_sandbox', () {
    defineTests(fileSystemContext);
  });
}

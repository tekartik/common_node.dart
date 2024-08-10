@TestOn('node')
// Copyright (c) 2015, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library;

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_test/fs_test.dart';

import 'test_common_node.dart';

void main() {
  var fileSystemContext = FileSystemTestContextNode('fs_node');
  FileSystem fs = fileSystemContext.fs;

  group('fs_node', () {
    test('context', () {
      expect(fileSystemContext.platform.isIo, isTrue);
      expect(
          (fileSystemContext.platform as PlatformContextNode).isIoNode, isTrue);
    });
    test('basics', () {
      expect(fs.supportsFileLink, isFalse);
      expect(fs.supportsLink, isFalse);
      expect(fs.supportsRandomAccess, isFalse);
    });

    test('name', () {
      expect(fs.name, 'node_io');
    });

    // All tests
    defineTests(fileSystemContext);
  });
}

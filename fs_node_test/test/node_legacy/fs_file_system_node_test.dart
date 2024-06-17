@TestOn('node')
// Copyright (c) 2015, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library fs_shim.fs_file_node_test;

import 'package:tekartik_fs_test/fs_shim_file_system_test.dart';

import 'test_common_node.dart';
import 'test_setup.dart';

void main() {
  nodeTestSetup();
  var fileSystemContext = FileSystemTestContextNode('fs_file_system');
  // All tests
  defineTests(fileSystemContext);
}

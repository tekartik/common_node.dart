@TestOn('node')
// Copyright (c) 2015, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library;

import 'package:tekartik_stdio_node/src/stdio_node_interop.dart';
import 'package:test/test.dart';

void main() {
  group('stdio_node_interop', () {
    test('out', () {
      print('jsProcess: $jsProcess');
      print('stdin: ${jsProcess.stdin}');
      print('stdout: ${jsProcess.stdout}');
    });
  });
}

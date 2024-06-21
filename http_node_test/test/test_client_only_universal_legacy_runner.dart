// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tekartik_fs_test/test_common.dart';
import 'package:tekartik_http_node/http_universal.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var factory = httpFactoryUniversal;
  var uri = platform.environment[uriVarKey];
  // uri = devWarning('http://localhost:8181');
  EchoServerClient? client;
  if (uri != null) {
    client = EchoServerClient(factory: factory.client, uri: Uri.parse(uri));
  }
  group('echo client', () {
    if (uri != null) {
      run(client!);
    }
    test('on', () {
      // fail('ok test running');
    });
  }, skip: uri == null ? 'skipped for no uri' : false);
}

@TestOn('vm')
library;

// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:dev_build/build_support.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  late Uri uri;
  late HttpServerState echoServeState;
  setUpAll(() async {
    echoServeState = await echoServe(httpServerFactoryIo, 0);
    uri = echoServeState.uri;
  });
  tearDownAll(() async {
    await echoServeState.close();
  });

  test('io', () async {
    var shell = Shell(
      environment: ShellEnvironment()..vars[uriVarKey] = uri.toString(),
    );
    await shell.run(
      'dart test -p vm test/test_client_only_universal_runner.dart',
    );
  });
  test('node', () async {
    if (isNodeSupportedSync) {
      var shell = Shell(
        environment: ShellEnvironment()..vars[uriVarKey] = uri.toString(),
      );
      await shell.run(
        'dart test -p node test/test_client_only_universal_runner.dart',
      );
    }
  });
}

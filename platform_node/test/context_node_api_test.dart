@TestOn('vm || node')
library tekartik_context_node.test.context_node_api_test;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

Future main() async {
  group('context_node_api', () {
    test('multiplatform', () async {
      platformContextUniversal;
    });
    test('io', () async {
      try {
        platformContextIo;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}
    });
    test('node', () async {
      try {
        platformContextNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
}

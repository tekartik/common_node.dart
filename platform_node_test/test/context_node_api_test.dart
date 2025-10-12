library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_browser/context_browser.dart';
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
    test('js', () async {
      try {
        platformContextNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
  group('any context', () {
    var platform = isRunningInNodeOrIo
        ? platformContextUniversal
        : platformContextBrowser;
    print('platform=$platform');
  });
}

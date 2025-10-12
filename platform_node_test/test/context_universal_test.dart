library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_platform_browser/context_browser.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

var platformContext = isRunningInNodeOrIo
    ? platformContextUniversal
    : platformContextBrowser;
void main() {
  var isBrowserEnv = kDartIsWeb && !isRunningInNode;
  var isNodeEnv = isRunningInNode;
  final platform = platformContext.platform;
  var environment = platform?.environment;
  final browser = platformContext.browser;
  final node = platformContext.node;
  final io = platformContext.io;
  var isIoEnv = !kDartIsWeb;
  group('unversal', () {
    test('platformContext', () {
      expect(platformContext, isNotNull);
      print('platformContext: $platformContext');

      if (isNodeEnv) {
        expect(platformContext, platformContextNode);
        print('platform: $platform');
        expect(node, isNotNull);
        expect(environment, isNotNull);
        print('environment: ${environment.toString().truncate(80)}');
      } else if (isBrowserEnv) {
        expect(platformContext, platformContextBrowser);
        expect(browser, isNotNull);
        expect(environment, isNull);
        print('environment: $environment');
      } else if (isIoEnv) {
        expect(platformContext, platformContextIo);
        print('platform: $platform');
        expect(io, isNotNull);
        expect(environment, isNotNull);
        print('environment: ${environment.toString().truncate(80)}');
      }
    });
  });
  // platformContext: [io] {platform: linux}
  // platformContext: [node] {platform: linux}
  // platformContext: {browser: {navigator: chrome, version: 141.0.0+0, os: {platform: linux}}}
}

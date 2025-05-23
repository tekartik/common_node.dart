@TestOn('node')
library;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('node', () {
    test('info', () {
      expect(platformContextNode.node, isNotNull);
      var map = platformContextNode.toMap();
      if (platformContextNode.node!.isLinux) {
        expect(platformContextNode.platform!.isLinux, isTrue);
        expect(map, {
          'node': {'platform': 'linux'},
        });
      } else if (platformContextNode.node!.isWindows) {
        expect(platformContextNode.platform!.isWindows, isTrue);
        expect(map, {
          'node': {'platform': 'windows'},
        });
      } else if (platformContextNode.node!.isMacOS) {
        expect(platformContextNode.platform!.isMacOS, isTrue);
        expect(map, {
          'node': {'platform': 'macos'},
        });
      }
    });
    test('nodeVersion', () {
      expect(nodeVersion, greaterThan(Version(8, 0, 0)));
    });
  });
}

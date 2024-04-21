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
      expect(map, {
        'node': {'platform': 'linux'}
      });
    });
    test('nodeVersion', () {
      expect(nodeVersion, greaterThan(Version(18, 0, 0)));
    });
  });
}

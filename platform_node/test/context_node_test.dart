@TestOn('node')
library tekartik_platform_node.context_node_test;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('node', () {
    test('info', () {
      expect(platformContextNode.node, isNotNull);
    });
    test('nodeVersion', () {
      expect(nodeVersion, greaterThan(Version(8, 0, 0)));
    });
  });
}

// ignore_for_file: avoid_print

@TestOn('node')
library;

import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('nodejs', () {
    test('isNodeJS', () {
      expect(isRunningInNode, isTrue);
      expect(isRunningInNodeOrIo, isTrue);
      print(platformContextNode.node);
    });
  });
}

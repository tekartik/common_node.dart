@TestOn('vm')
library;

import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('node io', () {
    test('isRunningInNode', () {
      expect(isRunningInNode, isFalse);
      expect(isRunningInNodeOrIo, isTrue);
    });
  });
}

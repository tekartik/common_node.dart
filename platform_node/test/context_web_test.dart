@TestOn('browser')
library;

import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  group('web node', () {
    test('isRunningInNode', () {
      expect(isRunningInNode, isFalse);
      expect(isRunningInNodeOrIo, isFalse);
    });
  });
}

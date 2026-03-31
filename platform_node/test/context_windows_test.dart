@TestOn('windows')
library;

import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

void main() {
  group('platform', () {
    test('isWindows', () {
      expect(platform.isWindows, isTrue);
    });
  });
}

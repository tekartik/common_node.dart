library;

import 'package:tekartik_stdio_node/process.dart';
import 'package:test/test.dart';

void main() {
  group('process', () {
    test('access', () {
      expect(process, isNotNull);
    });
  });
}

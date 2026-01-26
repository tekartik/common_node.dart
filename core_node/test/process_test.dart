@TestOn('node')
library;

import 'package:tekartik_core_node/process.dart';
import 'package:test/test.dart';

void main() {
  test('cwd', () {
    // ignore: avoid_print
    print('cwd(): ${process.cwd()}');
  });
}

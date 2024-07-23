@TestOn('node')
library;

import 'dart:js_interop';

import 'package:tekartik_core_node/require.dart';
import 'package:tekartik_core_node/src/require.dart';
import 'package:test/test.dart';

void main() {
  test('require', () {
    expect(require<JSObject>('fs'), isNotNull);
    expect(() => require<JSObject>('dummy'), throwsA(isA<JSObject>()));
  });
}

@TestOn('node')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_core_node/exports.dart';
import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:test/test.dart';

void main() {
  test('exports', () {
    expect(exports, isNotNull);
    exports.setProperty('tekartik_test'.toJS, 'test'.toJS);
    var map = jsObjectAsMap(exports);
    expect(map['tekartik_test'], 'test');
  });
}

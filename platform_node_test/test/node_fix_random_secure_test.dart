import 'dart:math';

import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  test(
    'nodeFixRandomSecure',
    () {
      // On node (dart test preamble) true until node_preamble or dart2js
      // read crypto on globalThis, false elsewhere.
      var fixed = nodeFixRandomSecure();
      if (!isRunningInNode) {
        expect(fixed, isFalse);
      }
      expect(Random.secure().nextInt(10), inInclusiveRange(0, 9));
      // Applied once.
      expect(nodeFixRandomSecure(), isFalse);
    },
    // No global crypto before node 19, Random.secure() cannot work.
    skip: isRunningInNode && nodeVersion.major < 19
        ? 'No global crypto before node 19'
        : null,
  );
}

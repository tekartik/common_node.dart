@TestOn('vm')
library;

import 'package:tekartik_stdio_node/readline.dart';
import 'package:test/test.dart';

void main() {
  test('close twice', () async {
    // The second close used to fail with an unhandled
    // 'Stdin has already been terminated.' error.
    readline.close();
    readline.close();
    // Let an unhandled async error, if any, reach the test zone.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }, timeout: const Timeout(Duration(seconds: 10)));
}

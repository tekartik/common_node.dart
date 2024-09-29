@TestOn('vm || node')
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:test/test.dart';

Future main() async {
  group('http_node_api', () {
    test('httpClientFactoryNode', () async {
      try {
        httpClientFactoryNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
}

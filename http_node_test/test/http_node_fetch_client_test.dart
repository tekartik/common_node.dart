@TestOn('node')
library;

import 'package:tekartik_http_node/http_client_node_fetch.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:test/test.dart';

void main() {
  runEchoServerClientTests(httpClientFactoryNodeFetch);
}

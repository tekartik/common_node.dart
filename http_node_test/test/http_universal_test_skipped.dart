library tekartik_http_node.http_node_test;

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/http_universal.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

bool get runningOnTravis => platform.environment['TRAVIS'] == 'true';
bool get runningOnGithubActions =>
    platform.environment['GITHUB_ACTIONS'] == 'true';
bool get runningOnNode => platformContextUniversal.node == null;
var supportsLocalHttpServer = !(runningOnNode && runningOnGithubActions);

void main() {
  var httpFactory = httpFactoryUniversal;
  if (supportsLocalHttpServer) {
    run(httpFactory);
  }
  test('server', () async {
    var server = await httpFactory.server.bind(localhost, 0);
    // print('### PORT ${server.port}');
    server.listen((request) {
      request.response
        ..write('test')
        ..close();
    });
    var client = httpFactory.client.newClient();
    expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
        'test');
    client.close();
    await server.close();
  }, skip: !supportsLocalHttpServer);
  test('localhost', () async {
    var server = await httpFactory.server.bind(localhost, 0);
    // print('### PORT ${server.port}');
    server.listen((request) {
      request.response
        ..write('test')
        ..close();
    });
    var client = httpFactory.client.newClient();
    expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
        'test');
    client.close();
    await server.close();
  }, skip: !supportsLocalHttpServer);
}

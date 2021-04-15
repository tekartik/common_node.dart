@TestOn('node')
library tekartik_http_node.http_node_test;

import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_platform_node/src/interop/platform_interop.dart';
import 'package:tekartik_http_node/http_node.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';

bool get runningOnTravis => Platform.environment['TRAVIS'] == 'true';

void main() {
  run(httpFactoryNode);
  test('localhost', () async {
    var server = await httpFactoryNode.server.bind(localhost, 0);
    // print('### PORT ${server.port}');
    server.listen((request) {
      request.response
        ..write('test')
        ..close();
    });
    var client = httpFactoryNode.client.newClient();
    expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
        'test');
    client.close();
    await server.close();
  });
  test('connected', () async {
    var client = httpFactoryNode.client.newClient();
    var content = await client.read(Uri.parse('https://api.github.com'),
        headers: {'User-Agent': 'tekartik_http_node'});
    var map = jsonDecode(content) as Map;
    expect(map['current_user_url'], 'https://api.github.com/user');
  }, skip: runningOnTravis);
}

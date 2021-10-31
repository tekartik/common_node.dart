import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/http_universal.dart';

Future<void> main() async {
  var httpServerFactory = httpFactoryUniversal.server;
  var httpClientFactory = httpFactoryUniversal.client;
  var server = await httpServerFactory.bind(localhost, 0);
  // print('### PORT ${server.port}');
  server.listen((request) {
    request.response
      ..write('test')
      ..close();
  });
  var client = httpClientFactory.newClient();
  print(await client.read(Uri.parse('http://$localhost:${server.port}')));
  client.close();
  await server.close();
}

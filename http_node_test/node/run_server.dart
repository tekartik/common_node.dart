import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_node/http_server_node.dart';

Future<void> main() async {
  var httpServerFactory = httpServerFactoryNode;
  var httpClientFactory = httpClientFactoryNode;
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

import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

import 'node/import_node.dart' as http;

class HttpClientFactoryNode implements HttpClientFactory {
  @override
  http.Client newClient() {
    return http.NodeClient();
  }
}

HttpClientFactoryNode? _httpClientFactoryNode;

HttpClientFactoryNode get httpClientFactoryNode =>
    _httpClientFactoryNode ??= HttpClientFactoryNode();

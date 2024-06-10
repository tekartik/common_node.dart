import 'package:fetch_client/fetch_client.dart' as fetch;
import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryNodeFetch implements HttpClientFactory {
  @override
  http.Client newClient() {
    return fetch.FetchClient();
  }
}

HttpClientFactoryNodeFetch? _httpClientFactoryNodeFetch;

HttpClientFactoryNodeFetch get httpClientFactoryNodeFetch =>
    _httpClientFactoryNodeFetch ??= HttpClientFactoryNodeFetch();

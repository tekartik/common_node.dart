import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/src/node_fetch/node_client_fetch.dart'
    as impl;

HttpClientFactory get httpClientFactoryNodeFetch =>
    impl.httpClientFactoryNodeFetch;

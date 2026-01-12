import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_node/http_client_node_fetch.dart';

/// Global universal http factory.
HttpFactory get httpFactoryUniversal => isRunningAsJavascript
    ? throw UnsupportedError('not supported')
    : httpFactoryIo;

/// Global universal http client factory.
HttpClientFactory get httpClientFactoryUniversal =>
    isRunningAsJavascript ? httpClientFactoryNodeFetch : httpClientFactoryIo;

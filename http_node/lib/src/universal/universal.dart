import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_node/http_client_node_fetch.dart';

HttpFactory get httpFactoryUniversal => isRunningAsJavascript
    ? throw UnsupportedError('not supported')
    : httpFactoryIo;

HttpClientFactory get httpClientFactoryUniversal =>
    isRunningAsJavascript ? httpClientFactoryNodeFetch : httpClientFactoryIo;

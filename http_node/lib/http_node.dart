import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/src/universal_legacy/universal.dart'
    as universal;
export 'package:tekartik_http_node/src/export/export.dart' show httpFactoryNode;

@Deprecated('import http_universal_legacy.dart')
HttpFactory get httpFactoryUniversal => universal.httpFactoryUniversal;

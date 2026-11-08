/// Uses new interop.
library;

export 'package:tekartik_http/http_client.dart';
// Conditional: package:http BrowserClient (js interop) does not compile on
// the VM, where httpClientFactoryNodeFetch throws.
export 'package:tekartik_http_node/src/export_fetch/export.dart'
    show httpClientFactoryNodeFetch;

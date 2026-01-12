import '../process.dart';
import 'platform_none.dart'
    if (dart.library.js_interop) 'platform_node.dart'
    if (dart.library.io) 'platform_io.dart'
    as impl;

/// Global process instance.
Process get process => impl.process;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_node/context_node.dart';

export 'export_stub.dart' if (dart.library.js_interop) 'export_node.dart';

/// true in node js mode or io mode, false otherwise
final isRunningInNodeOrIo = !kDartIsWeb || isRunningInNode;

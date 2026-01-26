import 'package:tekartik_core_node/src/node/process_interop.dart';
import 'package:tekartik_core_node/src/process.dart';

class _ProcessNode implements Process {
  // Exit the process
  @override
  void exit(int code) {
    jsProcess.exit(code);
  }

  @override
  String cwd() {
    return jsProcess.cwd();
  }
}

/// Global process instance.
final Process processNode = _ProcessNode();

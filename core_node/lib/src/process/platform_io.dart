//import '../../new_platform.dart' hide platform;
import 'dart:io' as io;

import '../process.dart';

class _ProcessIo implements Process {
  @override
  void exit(int code) {
    io.exit(code);
  }

  @override
  String cwd() {
    return io.Directory.current.path;
  }
}

final _processIo = _ProcessIo();

/// Global process instance.
Process get process => _processIo;

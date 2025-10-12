//import '../../new_platform.dart' hide platform;
import 'dart:io' as io;

import '../process.dart';

class _ProcessIo implements Process {
  @override
  void exit(int code) {
    io.exit(code);
  }
}

final _processIo = _ProcessIo();
Process get process => _processIo;

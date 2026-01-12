import '../process.dart';

class _ProcessNone extends Process {
  @override
  void exit(int code) {
    // Noop
  }
}

final _processNone = _ProcessNone();

/// Global process instance.
Process get process => _processNone;

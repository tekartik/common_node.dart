import '../process.dart';

class _ProcessNone extends Process {
  @override
  void exit(int code) {
    // Noop
  }

  @override
  String cwd() {
    throw UnimplementedError('cwd is not implemented on this platform');
  }
}

final _processNone = _ProcessNone();

/// Global process instance.
Process get process => _processNone;

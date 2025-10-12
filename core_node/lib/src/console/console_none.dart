import 'console.dart';

class NoneConsole extends Console {
  @override
  final err = NonConsoleSink();

  @override
  final out = NonConsoleSink();
}

final NoneConsole console = NoneConsole();

class NonConsoleSink implements ConsoleSink {
  @override
  void writeln([Object? object = '']) {}
}

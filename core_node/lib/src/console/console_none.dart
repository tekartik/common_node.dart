import 'console.dart';

/// None console implementation.
class NoneConsole extends Console {
  @override
  final err = NonConsoleSink();

  @override
  final out = NonConsoleSink();
}

/// Global none console instance.
final NoneConsole console = NoneConsole();

/// Non console sink implementation.
class NonConsoleSink implements ConsoleSink {
  @override
  void writeln([Object? object = '']) {}
}

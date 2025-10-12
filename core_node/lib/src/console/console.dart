import 'console_none.dart'
    if (dart.library.js_interop) 'console_node.dart'
    if (dart.library.io) 'console_io.dart'
    as impl;

abstract class Console {
  ConsoleSink get out;
  ConsoleSink get err;
}

abstract class ConsoleSink extends Object {
  void writeln([Object? obj = '']);
}

Console get console => impl.console;

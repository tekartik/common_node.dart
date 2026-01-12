import 'console_none.dart'
    if (dart.library.js_interop) 'console_node.dart'
    if (dart.library.io) 'console_io.dart'
    as impl;

/// Console interface.
abstract class Console {
  /// Output sink.
  ConsoleSink get out;

  /// Error sink.
  ConsoleSink get err;
}

/// Console sink interface.
abstract class ConsoleSink extends Object {
  /// Write a line.
  void writeln([Object? obj = '']);
}

/// Global console instance.
Console get console => impl.console;

import 'dart:io';

import 'console.dart';
//import '../../new_console.dart' hide console;

class _Console implements Console {
  @override
  final _ConsoleSink out = _ConsoleSink(stdout);
  @override
  final _ConsoleSink err = _ConsoleSink(stderr);
}

class _ConsoleSink implements ConsoleSink {
  final IOSink ioSink;
  _ConsoleSink(this.ioSink);

  @override
  void writeln([Object? obj = '']) {
    ioSink.writeln(obj);
  }
}

Console console = _Console();

library;

import 'dart:js_interop';

import 'console.dart';

class _Console implements Console {
  @override
  final _ConsoleSink out = _ConsoleOutSink();
  @override
  final _ConsoleSink err = _ConsoleErrorSink();
}

@JS('console.error')
external void _consoleError(JSAny? object);

@JS('console.log')
external void _consoleLog(JSAny? object);

class _ConsoleErrorSink extends _ConsoleSink {
  @override
  void writeln([Object? obj = '']) {
    // devPrint('err.writeln($obj)');
    _consoleError(obj?.jsify());
  }
}

class _ConsoleOutSink extends _ConsoleSink {
  @override
  void writeln([Object? obj = '']) {
    // devPrint('out.writeln($obj)');
    _consoleLog(obj?.jsify());
  }
}

abstract class _ConsoleSink implements ConsoleSink {}

/// Global console instance.
final Console console = _Console();

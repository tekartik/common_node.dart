// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:js';
import 'dart:typed_data';

import 'package:node_interop/node.dart';
import 'package:node_interop/stream.dart';
import 'package:tekartik_fs_node/src/node_legacy/file_node.dart';
import 'package:tekartik_js_utils/js_utils_import.dart';

abstract class HasReadable {
  Readable get nativeInstance;
}

/// [Stream] wrapper around Node's [Readable] stream.
class ReadableStream<T> extends Stream<T> implements HasReadable {
  /// Native `Readable` instance wrapped by this stream.
  ///
  /// It is not recommended to interact with this object directly.
  @override
  final Readable nativeInstance;
  final Object? Function(dynamic data)? _convert;
  late StreamController<T> _controller;

  /// Creates new [ReadableStream] which wraps [nativeInstance] of `Readable`
  /// type.
  ///
  /// The [convert] hook is called for each element of this stream before it's
  /// send to the listener. This allows implementations to convert raw
  /// JavaScript data in to desired Dart representation. If no convert
  /// function is provided then data is send to the listener unchanged.
  ReadableStream(this.nativeInstance, {T Function(dynamic data)? convert})
      : _convert = convert {
    _controller = StreamController(
        onPause: _onPause, onResume: _onResume, onCancel: _onCancel);
    nativeInstance.on('error', allowInterop(_errorHandler));
  }

  void _errorHandler([dynamic error]) {
    _controller.addError(error as JsError);
  }

  void _onPause() {
    nativeInstance.pause();
  }

  void _onResume() {
    nativeInstance.resume();
  }

  void _onCancel() {
    nativeInstance.removeAllListeners('data');
    nativeInstance.removeAllListeners('end');
    _controller.close();
  }

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    nativeInstance.on('data', allowInterop((Object chunk) {
      var data = (_convert == null) ? chunk : _convert(chunk);
      _controller.add(data as T);
    }));
    nativeInstance.on('end', allowInterop(() {
      _controller.close();
    }));

    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// [StreamSink] wrapper around Node's [Writable] stream.
class WritableStream<S> implements StreamSink<S> {
  /// Native JavaScript Writable wrapped by this stream.
  ///
  /// It is not recommended to interact with this object directly.
  final Writable nativeInstance;
  final dynamic Function(S data)? _convert;

  Completer? _drainCompleter;

  /// Creates [WritableStream] which wraps [nativeInstance] of `Writable`
  /// type.
  ///
  /// The [convert] hook is called for each element of this stream sink before
  /// it's added to the [nativeInstance]. This allows implementations to convert
  /// Dart objects in to values accepted by JavaScript streams. If no convert
  /// function is provided then data is sent to target unchanged.
  WritableStream(this.nativeInstance, {dynamic Function(S data)? convert})
      : _convert = convert {
    nativeInstance.on('error', allowInterop(_errorHandler));
  }

  Object? _closeError;

  void _errorHandler(JsError error) {
    _closeError = error;
    // devPrint('_errorHandler $error');
    if (_drainCompleter != null && !_drainCompleter!.isCompleted) {
      _drainCompleter!.completeError(error);
    } else if (_closeCompleter != null && !_closeCompleter!.isCompleted) {
      _closeCompleter!.completeError(error);
    } else {}
  }

  /// Writes [data] to nativeStream.
  void _write(S data) {
    var completer = Completer<void>();
    void handleFlush([JsError? error]) {
      if (completer.isCompleted) return;
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    }

    var chunk = (_convert == null) ? data : _convert(data);
    nativeInstance.write(chunk, allowInterop(handleFlush)) as bool;
    // !isFlushed) {
    var previous = _drainCompleter;
    _drainCompleter = completer;
    if (previous != null) {
      drain.whenComplete(() {});
    }
  }

  /// Returns Future which completes once all buffered data is accepted by
  /// underlying target.
  ///
  /// If there is no buffered data to drain then returned Future completes in
  /// next event-loop iteration.
  Future<void> get drain async {
    if (_drainCompleter != null) {
      try {
        await _drainCompleter!.future;
      } catch (e) {
        _closeError ??= e;
      }
    }
    return Future.value();
  }

  @override
  void add(S data) {
    _write(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    nativeInstance.emit('error', error);
  }

  @override
  Future addStream(Stream<S> stream) {
    throw UnimplementedError();
  }

  Completer? _closeCompleter;

  @override
  Future close() async {
    if (_closeError != null) {
      throw _closeError!;
    }
    _closeCompleter ??= () {
      var completer = Completer<void>.sync();

      void end([Object? error]) {
        if (!_closeCompleter!.isCompleted) {
          if (error != null || _closeError != null) {
            _closeCompleter!.completeError(error ?? _closeError!);
          } else {
            _closeCompleter!.complete();
          }
        }
      }

      nativeInstance.end(allowInterop(end));
      return completer;
    }();

    return await _closeCompleter!.future;
  }

  @override
  Future get done => close();
}

/// Writable stream of bytes, also accepts `String` values which are encoded
/// with specified [Encoding].
class NodeIOSink extends WritableStream<List<int>> {
  static dynamic _nodeIoSinkConvert(List<int> data) {
    if (data is! Uint8List) {
      data = Uint8List.fromList(data);
    }
    return Buffer.from(data);
  }

  NodeIOSink(super.nativeStream, {this.encoding = utf8})
      : super(convert: _nodeIoSinkConvert);

  Encoding encoding;

  Future flush() => drain;

  void write(Object? obj) {
    _write(encoding.encode(obj.toString()));
  }

  void writeAll(Iterable objects, [String separator = '']) {
    var data = objects.map((obj) => obj.toString()).join(separator);
    _write(encoding.encode(data));
  }

  void writeCharCode(int charCode) {
    _write(encoding.encode(String.fromCharCode(charCode)));
  }

  void writeln([Object? obj = '']) {
    _write(encoding.encode('$obj\n'));
  }
}

/// Writable stream of bytes, also accepts `String` values which are encoded
/// with specified [Encoding].
class NodeUint8ListSink extends WritableStream<Uint8List> {
  static dynamic _nodeIoSinkConvert(List<int> data) {
    if (data is! Uint8List) {
      data = Uint8List.fromList(data);
    }
    return Buffer.from(data);
  }

  NodeUint8ListSink(super.nativeStream, {this.encoding = utf8})
      : super(convert: _nodeIoSinkConvert);

  Encoding encoding;

  Future flush() => drain;

  void write(Object? obj) {
    _write(asUint8List(encoding.encode(obj.toString())));
  }

  void writeAll(Iterable objects, [String separator = '']) {
    var data = objects.map((obj) => obj.toString()).join(separator);
    _write(asUint8List(encoding.encode(data)));
  }

  void writeCharCode(int charCode) {
    _write(asUint8List(encoding.encode(String.fromCharCode(charCode))));
  }

  void writeln([Object? obj = '']) {
    _write(asUint8List(encoding.encode('$obj\n')));
  }
}

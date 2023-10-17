// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:fs_shim/fs.dart' as fs_shim;
import 'package:node_interop/fs.dart';
import 'package:node_interop/js.dart';
import 'package:node_interop/path.dart' as node_path;

import 'file_system_entity.dart';
import 'streams.dart';

List<int> _asIntList(dynamic list) =>
    list is List<int> ? list : (list as List).cast<int>();

class _ReadStream extends ReadableStream<Uint8List> {
  _ReadStream(ReadStream nativeStream)
      : super(nativeStream,
            convert: (chunk) => Uint8List.fromList(_asIntList(chunk)));
}

class _WriteStream extends NodeIOSink {
  _WriteStream(WriteStream nativeStream, Encoding encoding)
      : super(nativeStream, encoding: encoding);
}

/// A reference to a file on the file system.
///
/// A File instance is an object that holds a [path] on which operations can
/// be performed.
/// You can get the parent directory of the file using the getter [parent],
/// a property inherited from [FileSystemEntity].
///
/// Create a File object with a pathname to access the specified file on the
/// file system from your program.
///
///     var myFile = File('file.txt');
///
/// The File class contains methods for manipulating files and their contents.
/// Using methods in this class, you can open and close files, read to and write
/// from them, create and delete them, and check for their existence.
///
/// When reading or writing a file, you can use streams (with [openRead]),
/// random access operations (with [open]),
/// or convenience methods such as [readAsString],
///
/// Most methods in this class occur in synchronous and asynchronous pairs,
/// for example, [readAsString] and [readAsStringSync].
/// Unless you have a specific reason for using the synchronous version
/// of a method, prefer the asynchronous version to avoid blocking your program.
///
/// ## If path is a link
///
/// If [path] is a symbolic link, rather than a file,
/// then the methods of File operate on the ultimate target of the
/// link, except for [delete] and [deleteSync], which operate on
/// the link.
///
/// ## Read from a file
///
/// The following code sample reads the entire contents from a file as a string
/// using the asynchronous [readAsString] method:
///
///     import 'dart:async';
///
///     import 'package:node_io/node_file.dart';
///
///     void main() {
///       File('file.txt').readAsString().then((String contents) {
///         print(contents);
///       });
///     }
///
/// A more flexible and useful way to read a file is with a [Stream].
/// Open the file with [openRead], which returns a stream that
/// provides the data in the file as chunks of bytes.
/// Listen to the stream for data and process as needed.
/// You can use various transformers in succession to manipulate the
/// data into the required format or to prepare it for output.
///
/// You might want to use a stream to read large files,
/// to manipulate the data with transformers,
/// or for compatibility with another API.
///
///     import 'dart:convert';
///     import 'dart:async';
///
///     import 'package:node_io/node_file.dart';
///
///     main() {
///       final file = File('file.txt');
///       Stream<List<int>> inputStream = file.openRead();
///
///       inputStream
///         .transform(utf8.decoder)       // Decode bytes to UTF-8.
///         .transform(LineSplitter()) // Convert stream to individual lines.
///         .listen((String line) {        // Process results.
///             print('$line: ${line.length} bytes');
///           },
///           onDone: () { print('File is now closed.'); },
///           onError: (e) { print(e.toString()); });
///     }
///
/// ## Write to a file
///
/// To write a string to a file, use the [writeAsString] method:
///
///     import 'package:node_io/node_file.dart';
///
///     void main() {
///       final filename = 'file.txt';
///       File(filename).writeAsString('some content')
///         .then((File file) {
///           // Do something with the file.
///         });
///     }
///
/// You can also write to a file using a [Stream]. Open the file with
/// [openWrite], which returns an [file.IOSink] to which you can write data.
/// Be sure to close the sink with the [file.IOSink.close] method.
///
///     import 'package:node_io/node_file.dart';
///
///     void main() {
///       var file = File('file.txt');
///       var sink = file.openWrite();
///       sink.write('FILE ACCESSED ${DateTime.now()}\n');
///
///       // Close the IOSink to free system resources.
///       sink.close();
///     }
class File extends FileSystemEntity {
  @override
  final String path;

  File(this.path);

  File get absolute => File(_absolutePath);

  String get _absolutePath => node_path.path.resolve(path);

  Future<File> copy(String newPath) {
    final completer = Completer<File>();
    void callback(Object? err) {
      if (err != null) {
        completer.completeError(err);
      } else {
        completer.complete(File(newPath));
      }
    }

    final jsCallback = js.allowInterop(callback);
    fs.copyFile(_absolutePath, newPath, 0, jsCallback);
    return completer.future;
  }

  Future<File> create({bool recursive = false}) {
    // write an empty file
    final completer = Completer<File>();
    void callback(Object? err, [Object? fileDescriptor]) {
      if (err != null) {
        completer.completeError(err);
      } else {
        var fd = fileDescriptor as int;
        fs.close(fd, js.allowInterop((err) {
          if (err != null) {
            completer.completeError(err as Object);
          } else {
            completer.complete(this);
          }
        }));
      }
    }

    final jsCallback = js.allowInterop(callback);
    fs.open(_absolutePath, 'w', jsCallback);
    return completer.future;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    if (recursive) {
      return Future.error(
          UnsupportedError('Recursive delete is not supported by Node API'));
    }
    final completer = Completer<File>();
    void callback(Object? err) {
      if (err != null) {
        completer.completeError(err);
      } else {
        completer.complete(this);
      }
    }

    final jsCallback = js.allowInterop(callback);
    fs.unlink(_absolutePath, jsCallback);
    return completer.future;
  }

  Future<bool> exists() async {
    var stat = await FileStat.stat(path);
    return stat.type == fs_shim.FileSystemEntityType.file;
  }

  Future<DateTime> lastAccessed() =>
      FileStat.stat(path).then((stat) => stat.accessed);

  Future<DateTime> lastModified() =>
      FileStat.stat(path).then((stat) => stat.modified);

  Future<int> length() => FileStat.stat(path).then((stat) => stat.size);

  Stream<Uint8List> openRead([int? start, int? end]) {
    var options = ReadStreamOptions();
    if (start != null) options.start = start;
    if (end != null) options.end = end;
    var nativeStream = fs.createReadStream(path, options);
    return _ReadStream(nativeStream);
  }

  NodeIOSink openWrite(
      {fs_shim.FileMode mode = fs_shim.FileMode.write,
      Encoding encoding = utf8}) {
    assert(mode == fs_shim.FileMode.write || mode == fs_shim.FileMode.append);
    var flags = (mode == fs_shim.FileMode.append) ? 'a+' : 'w';
    var options = WriteStreamOptions(flags: flags);
    var stream = fs.createWriteStream(path, options);
    return _WriteStream(stream, encoding);
  }

  Future<Uint8List> readAsBytes() => openRead().fold(
      <int>[],
      (List<int> previous, List<int>? element) => previous
        ..addAll(element!)).then((List<int> list) => Uint8List.fromList(list));

  Future<List<String>> readAsLines({Encoding encoding = utf8}) {
    return encoding.decoder
        .bind(openRead())
        .transform(const LineSplitter())
        .toList();
  }

  Future<String> readAsString({Encoding encoding = utf8}) async {
    var bytes = await readAsBytes();
    return encoding.decode(bytes);
  }

  Future<File> rename(String newPath) {
    final completer = Completer<File>();
    void cb(Object? err) {
      if (err != null) {
        completer.completeError(err);
      } else {
        completer.complete(File(newPath));
      }
    }

    final jsCallback = js.allowInterop(cb);
    fs.rename(path, newPath, jsCallback);
    return completer.future;
  }

  Future<void> setLastAccessed(DateTime time) async {
    return _utimes(atime: Date(time.millisecondsSinceEpoch));
  }

  Future<void> setLastModified(DateTime time) async {
    return _utimes(mtime: Date(time.millisecondsSinceEpoch));
  }

  Future<void> _utimes({Date? atime, Date? mtime}) async {
    final currentStat = await stat();
    atime ??= Date(currentStat.accessed.millisecondsSinceEpoch);
    mtime ??= Date(currentStat.modified.millisecondsSinceEpoch);

    final completer = Completer<void>();
    void cb([Object? err]) {
      if (err != null) {
        completer.completeError(err);
      } else {
        completer.complete();
      }
    }

    final jsCallback = js.allowInterop(cb);
    fs.utimes(_absolutePath, atime, mtime, jsCallback);
    return completer.future;
  }

  Future<File> writeAsBytes(List<int> bytes,
      {fs_shim.FileMode mode = fs_shim.FileMode.write,
      bool flush = false}) async {
    var sink = openWrite(mode: mode);
    sink.add(bytes);
    if (flush) {
      await sink.flush();
    }
    await sink.close();
    return this;
  }

  Future<File> writeAsString(String contents,
      {fs_shim.FileMode mode = fs_shim.FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) async {
    var sink = openWrite(mode: mode, encoding: encoding);
    sink.write(contents);
    if (flush) {
      await sink.flush();
    }
    await sink.close();
    return this;
  }

  @override
  String toString() {
    return "File: '$path'";
  }
}

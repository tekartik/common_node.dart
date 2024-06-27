import 'dart:js_interop' as js;
import 'dart:math';
import 'dart:typed_data';

import 'package:tekartik_fs_node/src/utils.dart';
import 'package:tekartik_js_utils/js_utils_import.dart';

import '../import_common.dart';
import 'file_system_exception_node.dart';
import 'file_system_node.dart';
import 'fs_node_js_interop.dart' as node;
// ignore: unused_import
import 'import_js.dart' as js;

class FileNode extends FileSystemEntityNode
    with FileMixin, FileSystemEntityNodeMixin
    implements File {
  FileNode(super.fsNode, super.path);

  @override
  Future<File> create({bool recursive = false}) async {
    if (nodeIsDirectory()) {
      _throwIsADirectoryError();
    }
    if (recursive) {
      await parent.create(recursive: true);
    }
    if (!await parent.exists()) {
      throw FileSystemExceptionNode(
          message: 'Missing parent folder',
          path: path,
          status: FileSystemException.statusNotFound);
    }
    if (!await exists()) {
      await writeAsBytes(Uint8List(0));
    }
    return this;
  }

  void _throwIsADirectoryError([String? path]) {
    throw FileSystemExceptionNode(
        message: 'Is a directory',
        path: path ?? this.path,
        status: FileSystemException.statusIsADirectory);
  }

  @override
  Future<FileNode> delete({bool recursive = false}) async {
    if (nodeIsDirectory()) {
      _throwIsADirectoryError();
    }
    await _delete(recursive: recursive);
    return this;
  }

  @override
  Future<File> writeAsBytes(Uint8List bytes,
      {FileMode mode = FileMode.write, bool flush = false}) {
    return catchErrorAsync(() async {
      if (mode == FileMode.append) {
        await fsNode.nativeInstance
            .appendFileBytes(path, Uint8List.fromList(bytes).toJS)
            .toDart;
      } else {
        await fsNode.nativeInstance
            .writeFileBytes(path, Uint8List.fromList(bytes).toJS)
            .toDart;
      }
      return this;
    });
  }

  @override
  Future<FileSystemEntity> rename(String newPath) async {
    await nodeRename(newPath);
    return FileNode(fsNode, newPath);
  }

  @override
  Future<Uint8List> readAsBytes() {
    return catchErrorAsync(() async {
      var bytes =
          (await fsNode.nativeInstance.readFileBytes(path).toDart).toDart;
      return bytes;
    });
  }

  Future<void> _delete({bool recursive = false}) async {
    await catchErrorAsync(() async {
      await fsNode.nativeInstance
          .rm(path, node.JsFsRmOptions(recursive: recursive, force: recursive))
          .toDart;
    });
  }

  @override
  File get absolute => FileNode(fsNode, absolutePath);

  @override
  Future<File> copy(String newPath) async {
    await catchErrorAsync(() async {
      await fsNode.nativeInstance.cp(path, newPath).toDart;
    });
    return FileNode(fsNode, newPath);
  }

  @override
  String toString() => "File: '$path'";

  @override
  StreamSink<List<int>> openWrite(
      {FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    if (mode == FileMode.read) {
      throw ArgumentError('Invalid mode $mode in openWrite');
    }
    return WriteFileSinkNode(this, mode, encoding);
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    return ReadFileStreamCtrlNode(this, start, end).stream;
  }
}

String fileModeOpenFlags(FileMode mode) {
  switch (mode) {
    case FileMode.write:
      return 'w';
    case FileMode.append:
      return 'a';
    case FileMode.read:
      return 'r';
    default:
      throw UnimplementedError();
  }
}

class WriteFileSinkNode implements StreamSink<List<int>> {
  final FileNode fileNode;
  final FileMode mode;
  final Encoding encoding;
  final doneCompleter = Completer<void>();

  final _lock = Lock();
  Future<node.JsFsFileHandle>? _jsFileHandle;
  WriteFileSinkNode(this.fileNode, this.mode, this.encoding) {
    if (fileNode.nodeIsDirectory()) {
      return;
    }
    try {
      catchErrorSync(() {
        _jsFileHandle = fileNode.fsNode.nativeInstance
            .open(fileNode.path, fileModeOpenFlags(mode))
            .toDart;
      });
    } catch (e) {
      addError(e);
    }
  }

  @override
  void add(List<int> data) {
    if (_jsFileHandle == null) {
      return;
    }
    _lock.synchronized(() async {
      if (doneCompleter.isCompleted) {
        return;
      }
      try {
        await catchErrorAsync(() async {
          var jsFileHandle = await _jsFileHandle;
          await jsFileHandle!.write(asUint8List(data).toJS).toDart;
        });
      } catch (e) {
        addError(e);
      }
    });
  }

  // always flush on node
  @override
  Future close() async {
    if (fileNode.nodeIsDirectory()) {
      fileNode._throwIsADirectoryError(fileNode.path);
    }
    if (_jsFileHandle != null) {
      try {
        await _lock.synchronized(() async {
          await catchErrorAsync(() async {
            var jsFileHandle = await _jsFileHandle;
            await jsFileHandle!.close().toDart;
          });
          if (!doneCompleter.isCompleted) {
            doneCompleter.complete();
          }
        });
      } catch (e) {
        if (!doneCompleter.isCompleted) {
          doneCompleter.completeError(e);
        }
      }
    }
    return done;
  }

  @override
  void addError(errorEvent, [StackTrace? stackTrace]) {
    if (!doneCompleter.isCompleted) {
      doneCompleter.completeError(errorEvent, stackTrace);
    }
  }

  @override
  Future get done => doneCompleter.future;

  @override
  // not supported for node...
  Future addStream(Stream<List<int>> stream) async {
    await stream.listen((List<int> data) {
      add(data);
    }).asFuture<void>();
  }
}

class ReadFileStreamCtrlNode {
  final FileNode fileNode;
  final int? start;
  final int? end;

  late StreamController<Uint8List> _ctlr;
  late final node.JsFsFileHandle _jsFileHandle;

  static const _bufferSize = 64 * 1024;
  ReadFileStreamCtrlNode(this.fileNode, this.start, this.end) {
    _ctlr = StreamController(onListen: () async {
      try {
        await catchErrorAsync(() async {
          _jsFileHandle = await fileNode.fsNode.nativeInstance
              .open(fileNode.path, 'r')
              .toDart;
          var position = start ?? 0;
          while (true) {
            int bufferSize;
            if (end != null) {
              if (position >= end!) {
                break;
              }

              bufferSize = min(_bufferSize, end! - position);
            } else {
              bufferSize = _bufferSize;
            }
            var buffer = Uint8List(bufferSize).toJS;
            var result = await _jsFileHandle
                .read(buffer, 0, bufferSize, position)
                .toDart;
            if (result.bytesRead == 0) {
              break;
            }
            if (_ctlr.isClosed) {
              break;
            }
            _ctlr.add(buffer.toDart.sublist(0, result.bytesRead));
            position += result.bytesRead;
          }
          await _ctlr.close();
        });
      } catch (e) {
        _ctlr.addError(e);
      }
    }, onCancel: () {
      _ctlr.close();
    });
  }

  Stream<Uint8List> get stream => _ctlr.stream;
}

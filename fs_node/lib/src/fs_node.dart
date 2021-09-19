import 'dart:async';
import 'dart:typed_data';

import 'package:fs_shim/fs.dart' as fs;
import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/file_system_node.dart';
import 'package:tekartik_fs_node/src/import_common.dart';

import 'file_system_exception_node.dart';
import 'import_common_node.dart' as node;

export 'dart:async';
export 'dart:convert';

FileSystemNode? _fileSystemNode;

FileSystemNode get fileSystemNode => _fileSystemNode ??= FileSystemNode();

node.FileMode fileWriteMode(fs.FileMode fsFileMode) {
  return unwrapIoFileModeImpl(fsFileMode);
}

// FileMode Wrap/unwrap
FileMode wrapIoFileMode(node.FileMode ioFileMode) =>
    wrapIofileModeImpl(ioFileMode);

node.FileMode unwrapIoFileMode(FileMode fileMode) =>
    unwrapIoFileModeImpl(fileMode);

// FileSystemEntityType Wrap/unwrap
FileSystemEntityType wrapIoFileSystemEntityType(
        node.FileSystemEntityType ioFileSystemEntityType) =>
    wrapIoFileSystemEntityTypeImpl(ioFileSystemEntityType);

node.FileSystemEntityType unwrapIoFileSystemEntityType(
        FileSystemEntityType fileSystemEntityType) =>
    unwrapIoFileSystemEntityTypeImpl(fileSystemEntityType);

node.FileMode unwrapIoFileModeImpl(fs.FileMode fsFileMode) {
  switch (fsFileMode) {
    case fs.FileMode.write:
      return node.FileMode.write;
    case fs.FileMode.read:
      return node.FileMode.read;
    case fs.FileMode.append:
      return node.FileMode.append;
    default:
      throw UnsupportedError('invalid file mode $fsFileMode');
  }
}

fs.FileMode wrapIofileModeImpl(node.FileMode ioFileMode) {
  switch (ioFileMode) {
    case node.FileMode.write:
      return fs.FileMode.write;
    case node.FileMode.read:
      return fs.FileMode.read;
    case node.FileMode.append:
      return fs.FileMode.append;
    default:
      throw UnsupportedError('invalid file mode $ioFileMode');
  }
}

FileSystemExceptionNode ioWrapError(e) {
  // devPrint('error $e ${e.runtimeType}');
  if (e is node.FileSystemException) {
    return wrapIoFileSystemException(e); //FileSystemExceptionNode.io(e);
  } else {
    // print(e.toString());
    return FileSystemExceptionNode.fromString(e.toString());
  }
  // return e;
}

Future<T> ioWrap<T>(Future<T> future) async {
  try {
    return await future;
  } on node.FileSystemException catch (e) {
    //stderr.writeln(st);
    throw ioWrapError(e);
  } catch (e) {
    // catch anything in javascript
    throw ioWrapError(e);
  }
}

fs.FileSystemEntityType wrapIoFileSystemEntityTypeImpl(
    node.FileSystemEntityType type) {
  switch (type) {
    case node.FileSystemEntityType.file:
      return fs.FileSystemEntityType.file;
    case node.FileSystemEntityType.directory:
      return fs.FileSystemEntityType.directory;
    case node.FileSystemEntityType.link:
      return fs.FileSystemEntityType.link;
    case node.FileSystemEntityType.notFound:
      return fs.FileSystemEntityType.notFound;
    default:
      throw type;
  }
}

node.FileSystemEntityType unwrapIoFileSystemEntityTypeImpl(
    fs.FileSystemEntityType type) {
  switch (type) {
    case fs.FileSystemEntityType.file:
      return node.FileSystemEntityType.file;
    case fs.FileSystemEntityType.directory:
      return node.FileSystemEntityType.directory;
    case fs.FileSystemEntityType.link:
      return node.FileSystemEntityType.link;
    case fs.FileSystemEntityType.notFound:
      return node.FileSystemEntityType.notFound;
    default:
      throw type;
  }
}

class WriteFileSinkNode implements StreamSink<List<int>> {
  node.NodeIOSink ioSink;

  WriteFileSinkNode(this.ioSink);

  @override
  void add(List<int> data) {
    ioSink.add(data);
  }

  // always flush on node
  @override
  Future close() async {
    await ioWrap(ioSink.flush());
    await ioWrap(ioSink.close());
  }

  @override
  void addError(errorEvent, [StackTrace? stackTrace]) {
    ioSink.addError(errorEvent, stackTrace);
  }

  @override
  Future get done => ioWrap(ioSink.done);

  @override
  // not supported for node...
  Future addStream(Stream<List<int>> stream) async {
    await stream.listen((List<int> data) {
      add(data);
    }).asFuture();
  }
}

class ReadFileStreamCtrlNode {
  ReadFileStreamCtrlNode(this._nodeStream) {
    _ctlr = StreamController();
    _nodeStream.listen((data) {
      _ctlr.add(data);
    }, onError: (error, StackTrace stackTrace) {
      _ctlr.addError(ioWrapError(error));
    }, onDone: () {
      _ctlr.close();
    });
  }

  final Stream<Uint8List> _nodeStream;
  late StreamController<Uint8List> _ctlr;

  Stream<Uint8List> get stream => _ctlr.stream;
}

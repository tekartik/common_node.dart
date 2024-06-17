import 'dart:typed_data';

import 'package:tekartik_fs_node/src/import_common.dart';
import 'package:tekartik_fs_node/src/node_legacy/file_system_entity_node.dart';
import 'package:tekartik_fs_node/src/node_legacy/fs_node.dart';

//import 'package:fs_shim/src/common/compat.dart'; // ignore: implementation_imports

import 'import_common_node.dart' as node;

/// Concert a list to byte array
Uint8List asUint8List(List<int> bytes) {
  if (bytes is Uint8List) {
    return bytes;
  }
  return Uint8List.fromList(bytes);
}

Stream<Uint8List> intListStreamToUint8ListStream(Stream stream) {
  if (stream is Stream<Uint8List>) {
    return stream;
  } else if (stream is Stream<List<int>>) {
    return stream.transform(
        StreamTransformer<List<int>, Uint8List>.fromHandlers(
            handleData: (list, sink) {
      sink.add(Uint8List.fromList(list));
    }));
  } else {
    throw ArgumentError('Invalid stream type: ${stream.runtimeType}');
  }
}

Future<String> _wrapFutureString(Future<String> future) => ioWrap(future);

// Wrap/unwrap
FileNode wrapIoFile(node.File ioFile) => FileNode.io(ioFile);

node.File unwrapIoFile(File file) => (file as FileNode).nodeFile;

class FileNode extends FileSystemEntityNode with FileMixin implements File {
  FileNode.io(node.File super.file);

  FileNode(String path) : super(node.File(path));

  node.File get nodeFile => nativeInstance as node.File;

  @override
  Future<FileNode> create({bool recursive = false}) async {
    if (await exists()) {
      await delete();
    }
    if (recursive) {
      await pathRecursiveCreateParent(path);
    }
    await ioWrap(nodeFile.create(recursive: false));

    return this;
  }

  @override
  Future<FileNode> delete({bool recursive = false}) async {
    // if recursive is true, delete whetever types it is per definition
    if (recursive) {
      await fsNode.deleteAny(path);
      return this;
    }
    await super.delete();
    return this;
  }

  // ioFile.openWrite(mode: _fileMode(mode), encoding: encoding);
  @override
  StreamSink<List<int>> openWrite(
      {FileMode mode = FileMode.write, Encoding encoding = utf8}) {
    if (mode == FileMode.read) {
      throw ArgumentError.value(mode, 'mode cannot be read-only');
    }
    // Test that parent dir exists as we don't get any error...
    /*
    var dir = node.Directory(dirname(path));
    if (!dir.existsSync()) {
      throw 'Parent directory does not exists';
    }

     */
    var ioMode = fileWriteMode(mode);
    var ioSink = nodeFile.openWrite(mode: ioMode, encoding: encoding);
    final sink = WriteFileSinkNode(ioSink);

    return sink;
  }

  FileNode _me(_) => this;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    // Node is end inclusive!
    return ReadFileStreamCtrlNode(intListStreamToUint8ListStream(
            nodeFile.openRead(start, end != null ? end - 1 : null)))
        .stream;
  }

  @override
  Future<FileNode> rename(String newPath) async {
    await ioWrap(nodeFile.rename(newPath));
    return FileNode(newPath);
  }

  @override
  Future<FileNode> copy(String newPath) async {
    await ioWrap(nodeFile.copy(newPath));
    return FileNode(newPath);
  }

  @override
  Future<FileNode> writeAsBytes(List<int> bytes,
          {FileMode mode = FileMode.write, bool flush = false}) =>
      ioWrap(nodeFile.writeAsBytes(bytes,
              mode: fileWriteMode(mode), flush: flush))
          .then(_me);

  @override
  Future<FileNode> writeAsString(String contents,
          {FileMode mode = FileMode.write,
          Encoding encoding = utf8,
          bool flush = false}) =>
      ioWrap(nodeFile.writeAsString(contents,
              mode: fileWriteMode(mode), encoding: encoding, flush: flush))
          .then(_me);

  @override
  Future<Uint8List> readAsBytes() async =>
      asUint8List(await ioWrap(nodeFile.readAsBytes()));

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _wrapFutureString(nodeFile.readAsString(encoding: encoding));

  @override
  File get absolute => FileNode.io(nodeFile.absolute);

  @override
  String toString() => "File: '$path'";
}

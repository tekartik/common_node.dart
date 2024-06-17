import 'dart:js_interop' as js;
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../import_common.dart';
import 'fs_node_js_interop.dart' as node;
// ignore: unused_import
import 'import_js.dart' as js;

/// Basic implementation, no support for links yet
class FileSystemNode with FileSystemMixin implements FileSystem {
  final node.JsFs nativeInstance = node.jsFs;

  @override
  bool get supportsFileLink => false;

  @override
  bool get supportsRandomAccess => false;

  @override
  bool get supportsLink => false;

  @override
  String get name => 'node_io';

  @override
  p.Context get path => p.context;

  @override
  Future<FileSystemEntityType> type(String? path,
      {bool followLinks = true}) async {
    try {
      return await catchErrorAsync(() async {
        var fileStat = await nativeInstance.stat(path!).toDart;
        if (fileStat.isDirectory()) {
          return FileSystemEntityType.directory;
        } else if (fileStat.isFile()) {
          return FileSystemEntityType.file;
        }
        return FileSystemEntityType.notFound;
      }());
    } on FileSystemExceptionNode catch (_) {
      return FileSystemEntityType.notFound;
    }
  }

  @override
  FileNode file(String path) => FileNode(this, path);

  @override
  DirectoryNode directory(String path) => DirectoryNode(this, path);
}

abstract class FileSystemEntityNode implements FileSystemEntity {
  final FileSystemNode fsNode;
  @override
  final String path;

  FileSystemEntityNode(this.fsNode, this.path);
}

mixin FileSystemEntityNodeMixin on FileSystemEntityNode {
  @override
  FileSystem get fs => fsNode;

  @override
  bool get isAbsolute => p.isAbsolute(path);

  @override
  Future<bool> exists() async {
    try {
      await fsNode.nativeInstance.access(path).toDart;
      return true;
    } catch (e) {
      return false;
    }
  }

  String get absolutePath => p.normalize(p.absolute(path));

  @override
  Future<FileStat> stat() async {
    FileStatNode notFound() {
      return FileStatNode(
          mode: 0,
          modified: null,
          size: -1,
          type: FileSystemEntityType.notFound);
    }

    try {
      return await catchErrorAsync(() async {
        var jsFileStat = await fsNode.nativeInstance.stat(path).toDart;
        if (jsFileStat.isDirectory()) {
          return FileStatNode(
              mode: jsFileStat.mode,
              modified: null,
              size: jsFileStat.size,
              type: FileSystemEntityType.directory);
        } else if (jsFileStat.isFile()) {
          return FileStatNode(
              mode: 0,
              modified: null,
              size: -1,
              type: FileSystemEntityType.notFound);
        }
        return notFound();
      }());
    } on FileSystemExceptionNode catch (_) {
      return notFound();
    }
  }

  @override
  Future<FileSystemEntity> rename(String newPath) async {
    await catchErrorAsync(() async {
      await fsNode.nativeInstance.rename(path, newPath).toDart;
    }());

    return this;
  }

  @override
  Directory get parent => DirectoryNode(fsNode, p.dirname(path));
}

class FileNode extends FileSystemEntityNode
    with FileMixin, FileSystemEntityNodeMixin
    implements File {
  FileNode(super.fsNode, super.path);

  @override
  Future<File> create({bool recursive = false}) async {
    if (recursive) {
      await parent.create(recursive: true);
    }
    fsNode.nativeInstance.writeFileBytes(path, Uint8List(0).toJS);
    return this;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    await catchErrorAsync(() async {
      await fsNode.nativeInstance
          .rm(path, node.JsFsRmOptions(recursive: recursive, force: recursive))
          .toDart;
    }());
    return this;
  }

  @override
  File get absolute => FileNode(fsNode, absolutePath);

  @override
  String toString() => "File: '$path'";
}

class DirectoryNode extends FileSystemEntityNode
    with DirectoryMixin, FileSystemEntityNodeMixin
    implements Directory {
  DirectoryNode(super.fsNode, super.path);

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    await catchErrorAsync(() async {
      await fsNode.nativeInstance
          .rmdir(
              path, node.JsFsRmOptions(recursive: recursive, force: recursive))
          .toDart;
    }());
    return this;
  }

  @override
  Future<DirectoryNode> create({bool recursive = false}) async {
    try {
      await catchErrorAsync(() async {
        await fsNode.nativeInstance
            .mkdir(path, node.JsFsMkdirOptions(recursive: recursive))
            .toDart;
      }());
    } on FileSystemExceptionNode catch (e) {
      // devPrint('create.error: ${e.status}');
      if (e.status == FileSystemException.statusAlreadyExists) {
        // Already exists
      } else {
        rethrow;
      }
    }
    return this;
  }

  @override
  Directory get absolute => DirectoryNode(fsNode, absolutePath);

  @override
  String toString() => "Directory: '$path'";
}

Future<T> catchErrorAsync<T>(Future<T> future) async {
  try {
    return await future;
  } catch (e) {
    // print('Error: $e');

    if (e is js.JSObject) {
      // {errno: -17, code: EEXIST, syscall: mkdir, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub}
      // devPrint(js.jsAnyToDebugString(e));
      var jsFsError = e as node.JsFsError;
      // print('message: ${jsFsError.message}');
      // print('message: ${jsFsError.toString()}');
      // print('errno: ${jsFsError.errno}');
      // print('path: ${jsFsError.path}');

      // Error: SystemError [ERR_FS_EISDIR]: Path is a directory: rm returned EISDIR (is a directory) /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub
      // {code: ERR_FS_EISDIR, info: {code: EISDIR, message: is a directory, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub, syscall: rm, errno: 21}, errno: 21, syscall: rm, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub}
      throw FileSystemExceptionNode(
          message: jsFsError.message ?? jsFsError.toString(),
          path: jsFsError.path,
          status: jsFsError.errno?.abs());
    }

    rethrow;
  }
}

class FileSystemExceptionNode implements FileSystemException {
  @override
  final String message;

  @override
  final OSError? osError;

  @override
  final String? path;

  @override
  final int? status;

  FileSystemExceptionNode(
      {required this.message, this.osError, this.path, this.status});

  @override
  String toString() =>
      'FileSystemException(status: status, $message, path: $path)';
}

class FileStatNode implements FileStat {
  @override
  final int mode;

  final DateTime? _modified;

  @override
  DateTime get modified => _modified ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  final int size;

  @override
  final FileSystemEntityType type;

  FileStatNode(
      {required this.mode,
      required DateTime? modified,
      required this.size,
      required this.type})
      : _modified = modified;
}

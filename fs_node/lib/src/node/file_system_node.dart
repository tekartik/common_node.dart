import 'dart:js_interop' as js;

import 'package:path/path.dart' as p;
import 'package:tekartik_js_utils/js_utils_import.dart';

import '../import_common.dart';
import 'file_node.dart';
import 'file_system_exception_node.dart';
import 'fs_node_js_interop.dart' as node;
// ignore: unused_import
import 'import_js.dart' as js;

/// Basic implementation, no support for links yet
class FileSystemNode with FileSystemMixin implements FileSystem {
  final node.JsFs nativeInstance = node.jsFs;
  final node.JsFsSync nativeInstanceSync = node.jsFsSync;

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
        var fileStat = await nativeInstance.lstat(path!).toDart;
        if (fileStat.isDirectory()) {
          return FileSystemEntityType.directory;
        } else if (fileStat.isFile()) {
          return FileSystemEntityType.file;
        } else if (fileStat.isSymbolicLink()) {
          return FileSystemEntityType.link;
        }
        return FileSystemEntityType.notFound;
      });
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
        var jsFileStat = await fsNode.nativeInstance.lstat(path).toDart;
        // jsFileStat: {dev: 66311, mode: 33204, nlink: 1, uid: 1000, gid: 1000, rdev: 0, blksize: 4096, ino: 47590381, size: 4, blocks: 8, atimeMs: 1718633112014.787, mtimeMs: 1718633112014.787, ctimeMs: 1718633112014.787, birthtimeMs: 1718633112014.787, atime: {}, mtime: {}, ctime: {}, birthtime: {}}
        // devPrint('jsFileStat: ${js.jsAnyToDebugString(jsFileStat)}');
        //devPrint('jsFileStat modified: ${jsFileStat.mtime}');
        if (jsFileStat.isDirectory()) {
          //devPrint('isDirectory');
          return FileStatNode(
              mode: jsFileStat.mode,
              modified: DateTime.fromMillisecondsSinceEpoch(
                  jsFileStat.mtimeMs.toInt()),
              size: jsFileStat.size,
              type: FileSystemEntityType.directory);
        } else if (jsFileStat.isFile()) {
          //devPrint('isFile ${jsFileStat.mtimeMs}');
          return FileStatNode(
              mode: jsFileStat.mode,
              modified: DateTime.fromMillisecondsSinceEpoch(
                  jsFileStat.mtimeMs.toInt()),
              size: jsFileStat.size,
              type: FileSystemEntityType.file);
        }
        return notFound();
      });
    } on FileSystemExceptionNode catch (_) {
      return notFound();
    }
  }

  Future<void> nodeRename(String newPath) async {
    // Somehow on windows it might succeed to rename a directory over an empty
    // file so catch that before
    if (await fsNode.type(newPath) != FileSystemEntityType.notFound) {
      throw FileSystemExceptionNode(
          message: 'Already exists',
          status: FileSystemException.statusAlreadyExists,
          path: newPath);
    }
    await catchErrorAsync(() async {
      await fsNode.nativeInstance.rename(path, newPath).toDart;
    });
  }

  bool nodeIsDirectory() {
    try {
      var jsFileStat = fsNode.nativeInstanceSync.lstatSync(path);
      return jsFileStat.isDirectory();
    } catch (_) {
      return false;
    }
  }

  bool _isFile() {
    try {
      var jsFileStat = fsNode.nativeInstanceSync.lstatSync(path);
      return jsFileStat.isFile();
    } catch (_) {
      return false;
    }
  }

  void _throwIsNotADirectoryError([String? path]) {
    throw FileSystemExceptionNode(
        message: 'Not a directory',
        path: path ?? this.path,
        status: FileSystemException.statusNotADirectory);
  }

  @override
  Directory get parent => DirectoryNode(fsNode, p.dirname(path));
}

class DirectoryNode extends FileSystemEntityNode
    with DirectoryMixin, FileSystemEntityNodeMixin
    implements Directory {
  DirectoryNode(super.fsNode, super.path);

  @override
  Future<DirectoryNode> delete({bool recursive = false}) async {
    if (_isFile()) {
      _throwIsNotADirectoryError();
    }
    await catchErrorAsync(() async {
      if (!recursive) {
        try {
          await fsNode.nativeInstance.rm(path).toDart;
        } catch (_) {
          // For compat, it seems
          // SystemError [ERR_FS_EISDIR]: Path is a directory: rm returned EISDIR (is a directory)
          // ignore: deprecated_member_use_from_same_package
          await fsNode.nativeInstance.rmdir(path).toDart;
        }
      } else {
        await fsNode.nativeInstance
            .rm(path, node.JsFsRmOptions(recursive: recursive, force: true))
            .toDart;
      }
    });
    return this;
  }

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    var cancelled = false;
    late StreamController<FileSystemEntity> ctlr;
    ctlr = StreamController<FileSystemEntity>(
        sync: true,
        onListen: () async {
          try {
            await catchErrorAsync(() async {
              var files = (await fsNode.nativeInstance
                      .readdir(
                          path, node.JsFsReaddirOptions(recursive: recursive))
                      .toDart)
                  .toDart
                  .map((e) => e.toDart);

              for (var file in files) {
                var filePath = fsNode.path.join(path, file);
                var jsFileStat = fsNode.nativeInstanceSync.lstatSync(filePath);
                if (jsFileStat.isDirectory()) {
                  ctlr.add(DirectoryNode(fsNode, filePath));
                } else if (jsFileStat.isFile()) {
                  ctlr.add(FileNode(fsNode, filePath));
                }
              }
              //for (var i = 0; i < files.length; i++) {}
              await ctlr.close();
            });
          } catch (e) {
            if (!cancelled) {
              ctlr.addError(e);
              ctlr.close().unawait();
            }
          }

          /*
          while (!cancelled) {
            for (var file in files) {
              var filePath = file as String;
              // Need to append the original path to build a proper path
              filePath = p.join(path, filePath);
              var stat = FileStatNode(
                  mode: 0,
                  modified: null,
                  size: -1,
                  type: FileSystemEntityType.notFound);
              ctlr.add(stat);
            }
            ctlr.close();
          }*/
        },
        onCancel: () {
          cancelled = true;
        });
    return ctlr.stream;
    // TODO: implement list
    //return super.list(recursive, followLinks);
  }

  @override
  Future<DirectoryNode> create({bool recursive = false}) async {
    if (nodeIsDirectory()) {
      return this;
    }
    try {
      await catchErrorAsync(() async {
        await fsNode.nativeInstance
            .mkdir(path, node.JsFsMkdirOptions(recursive: recursive))
            .toDart;
      });
    } on FileSystemExceptionNode catch (e) {
      if (e.status == FileSystemException.statusAlreadyExists) {
        // Already exists
        var jsFileStat = fsNode.nativeInstanceSync.lstatSync(path);
        if (!jsFileStat.isDirectory()) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    return this;
  }

  @override
  Directory get absolute => DirectoryNode(fsNode, absolutePath);

  @override
  Future<FileSystemEntity> rename(String newPath) async {
    await nodeRename(newPath);
    return DirectoryNode(fsNode, newPath);
  }

  @override
  String toString() => "Directory: '$path'";
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

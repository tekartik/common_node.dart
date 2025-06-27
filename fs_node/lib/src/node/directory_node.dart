import 'dart:js_interop' as js;

import '../import_common.dart';
import 'file_node.dart';
import 'file_system_exception_node.dart';
import 'file_system_node.dart';
import 'fs_node_js_interop.dart' as node;
// ignore: unused_import
import 'import_js.dart' as js;

class DirectoryNode extends FileSystemEntityNode
    with DirectoryMixin, FileSystemEntityNodeMixin
    implements Directory {
  DirectoryNode(super.fsNode, super.path);

  @override
  Future<DirectoryNode> delete({bool recursive = false}) async {
    if (nodeIsFile()) {
      nodeThrowIsNotADirectoryError();
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
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    var cancelled = false;
    late StreamController<FileSystemEntity> ctlr;
    ctlr = StreamController<FileSystemEntity>(
      sync: true,
      onListen: () async {
        try {
          await catchErrorAsync(() async {
            var files =
                (await fsNode.nativeInstance
                        .readdir(
                          path,
                          node.JsFsReaddirOptions(recursive: recursive),
                        )
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
      },
    );
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
        // Already exists, make unit test happy
        if (!nodeIsDirectory() && platformContextNode.node?.isWindows != true) {
          throw FileSystemExceptionNode(
            message: 'Not a directory',
            status: FileSystemException.statusNotADirectory,
            path: path,
          );
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
    // Somehow on windows it might succeed to rename a directory over an empty
    // file so catch that before
    if (isWindows) {
      var type = await fsNode.type(newPath);
      if (type == FileSystemEntityType.file) {
        throw FileSystemExceptionNode(
          message: 'Not a directory',
          status: FileSystemException.statusNotADirectory,
          path: newPath,
        );
      }
      if (type != FileSystemEntityType.notFound) {
        throw FileSystemExceptionNode(
          message: 'Already exists',
          status: FileSystemException.statusAlreadyExists,
          path: newPath,
        );
      }
    }
    await nodeRename(newPath);
    return DirectoryNode(fsNode, newPath);
  }

  @override
  String toString() => "Directory: '$path'";
}

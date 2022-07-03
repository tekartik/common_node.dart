import 'package:path/path.dart';
import 'package:tekartik_fs_node/src/directory_node.dart';
import 'package:tekartik_fs_node/src/file_stat_node.dart';
import 'package:tekartik_fs_node/src/file_system_node.dart';
import 'package:tekartik_fs_node/src/import_common.dart';

import 'fs_node.dart';
import 'import_common_node.dart' as node;

abstract class FileSystemEntityNode implements FileSystemEntity {
  final node.FileSystemEntity nativeInstance;

  FileSystemEntityNode(this.nativeInstance);

  FileSystemEntity _me(_) => this;

  FileSystemNode get fsNode => fileSystemNode;

  @override
  FileSystem get fs => fsNode;

  @override
  String get path => nativeInstance.path;

  @override
  String toString() => nativeInstance.toString();

  @override
  Directory get parent => DirectoryNode(nativeInstance.parent.path);

  @override
  Future<bool> exists() async => pathExists(path);

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) //
      =>
      ioWrap(nativeInstance.delete(recursive: recursive)).then(_me);

  @override
  bool get isAbsolute => nativeInstance.isAbsolute;

  @override
  Future<FileStat> stat() async => pathFileStat(path);
}

Future<bool> pathExists(String path) async {
  var stat = await pathFileStat(path);
  return stat.type != FileSystemEntityType.notFound;
}

Future pathRecursiveCreateParent(String path) async {
  var parent = dirname(path);
  if (parent != path) {
    if (!await pathExists(parent)) {
      await pathRecursiveCreateParent(parent);
      await DirectoryNode(parent).create();
    }
  }
}

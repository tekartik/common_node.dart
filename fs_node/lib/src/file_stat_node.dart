import 'package:fs_shim/fs.dart';
import 'package:fs_shim/src/common/fs_mixin.dart'; // ignore: implementation_imports
import 'package:tekartik_fs_node/src/fs_node.dart';

import 'import_common_node.dart' as node;

// FileStat Wrap/unwrap
FileStatNode wrapIoFileStat(node.FileStat ioFileStat) =>
    FileStatNode.io(ioFileStat);

node.FileStat? unwrapIoFileStat(FileStat fileStat) =>
    (fileStat as FileStatNode).ioFileStat;

class FileStatNotFound extends FileStatNode {
  FileStatNotFound() : super.io(node.FileStat.notFound());

  @override
  int get size => -1;

  @override
  DateTime get modified => DateTime(0);

  @override
  FileSystemEntityType get type => FileSystemEntityType.notFound;

  @override
  String toString() => 'FileStat($type)';
}

class FileStatNode with FileStatModeMixin implements FileStat {
  FileStatNode.io(this.ioFileStat);

  node.FileStat ioFileStat;

  @override
  DateTime get modified => ioFileStat.modified;

  @override
  int get size => ioFileStat.size;

  @override
  FileSystemEntityType get type =>
      wrapIoFileSystemEntityTypeImpl(ioFileStat.type);

  @override
  String toString() => ioFileStat.toString();
}

Future<FileStatNode> pathFileStat(String path) async {
  try {
    // var stat = await ioWrap(nativeInstance.stat());
    var stat = (await ioWrap(node.FileStat.stat(path)));
    return FileStatNode.io(stat);
  } catch (e) {
    return FileStatNotFound();
  }
}

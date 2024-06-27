import 'dart:js_interop' as js;

import '../import_common.dart';
import 'fs_node_js_interop.dart' as node;
// ignore: unused_import
import 'import_js.dart' as js;

const _debugException = false;
// _debugException = devWarning(true);

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
      'FileSystemException(status: $status, $message, path: $path)';
}

bool get isWindows => platformContextNode.node?.isWindows ?? false;
bool _handleError(Object error) {
  if (error is js.JSObject) {
    // {errno: -17, code: EEXIST, syscall: mkdir, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub}
    if (_debugException) {
      // ignore: avoid_print
      print(js.jsAnyToDebugString(error));
    }

    var jsFsError = error as node.JsFsError;

    var errno = jsFsError.errno;
    if (isWindows) {
      // Perform some consistency in errors
      // windows
      // {errno: -4058, code: ENOENT, syscall: mkdir,
      if (errno == -4058) {
        errno = FileSystemException.statusNotFound;
      } else if (errno == -4048) {
        // {errno: -4048, code: EPERM, syscall: rename
        errno = FileSystemException.statusAlreadyExists;
      } else if (errno == -4051) {
        // {errno: -4051, code: ENOTEMPTY, syscall: rmdir
        errno = FileSystemException.statusNotEmpty;
      }
    }
    // print('message: ${jsFsError.message}');
    // print('message: ${jsFsError.toString()}');
    // print('errno: ${jsFsError.errno}');
    // print('path: ${jsFsError.path}');

    // Error: SystemError [ERR_FS_EISDIR]: Path is a directory: rm returned EISDIR (is a directory) /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub
    // {code: ERR_FS_EISDIR, info: {code: EISDIR, message: is a directory, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub, syscall: rm, errno: 21}, errno: 21, syscall: rm, path: /home/alex/tekartik/devx/git/github.com/tekartik/common_node.dart/fs_node_test/.dart_tool/tekartik_fs_node/test/fs/test1/sub}
    throw FileSystemExceptionNode(
        message: jsFsError.message ?? jsFsError.toString(),
        path: jsFsError.path,
        status: errno?.abs());
  }

  return false;
}

Future<T> catchErrorAsync<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (e) {
    _handleError(e);
    rethrow;
  }
}

T catchErrorSync<T>(T Function() action) {
  try {
    return action();
  } catch (e) {
    _handleError(e);
    rethrow;
  }
}

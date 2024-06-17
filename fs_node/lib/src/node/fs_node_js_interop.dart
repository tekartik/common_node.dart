import 'dart:js_interop' as js;

import 'package:tekartik_core_node/require.dart';
import 'import_js.dart' as js;

var jsFs = require<JsFs>('node:fs/promises');
var jsFsSync = require<JsFsSync>('node:fs');

extension type JsFsSync._(js.JSObject _) implements js.JSObject {}

extension JsFsSyncExt on JsFsSync {
  external JsFsStats lstatSync(String path);
}

extension type JsFs._(js.JSObject _) implements js.JSObject {}

extension JsFsExt on JsFs {
  /// Added in: v10.0.0
  /// path <string> | <Buffer> | <URL>
  /// Returns: <Promise> Fulfills with undefined upon success.
  /// If path refers to a symbolic link, then the link is removed without affecting the file or directory to which that link refers. If the path refers to a file path that is not a symbolic link, the file is deleted. See the POSIX unlink(2) documentation for more detail.
  external js.JSPromise unlink(String path);

  /// fsPromises.access(path[, mode])#
  /// Added in: v10.0.0
  /// path <string> | <Buffer> | <URL>
  /// mode <integer> Default: fs.constants.F_OK
  /// Returns: <Promise> Fulfills with undefined upon success.
  /// Tests a user's permissions for the file or directory specified by path. The mode argument is an optional integer that specifies the accessibility checks to be performed. mode should be either the value fs.constants.F_OK or a mask consisting of the bitwise OR of any of fs.constants.R_OK, fs.constants.W_OK, and fs.constants.X_OK (e.g. fs.constants.W_OK | fs.constants.R_OK). Check File access constants for possible values of mode.
  ///
  /// If the accessibility check is successful, the promise is fulfilled with no value. If any of the accessibility checks fail, the promise is rejected with an <Error> object. The following example checks if the file /etc/passwd can be read and written by the current process.
  external js.JSPromise access(String path);

  /// fsPromises.rm(path[, options])#
  /// Added in: v14.14.0
  /// path <string> | <Buffer> | <URL>
  /// options <Object>
  /// force <boolean> When true, exceptions will be ignored if path does not exist. Default: false.
  /// maxRetries <integer> If an EBUSY, EMFILE, ENFILE, ENOTEMPTY, or EPERM error is encountered, Node.js will retry the operation with a linear backoff wait of retryDelay milliseconds longer on each try. This option represents the number of retries. This option is ignored if the recursive option is not true. Default: 0.
  /// recursive <boolean> If true, perform a recursive directory removal. In recursive mode operations are retried on failure. Default: false.
  /// retryDelay <integer> The amount of time in milliseconds to wait between retries. This option is ignored if the recursive option is not true. Default: 100.
  /// Returns: <Promise> Fulfills with undefined upon success.
  /// Removes files and directories (modeled on the standard POSIX rm utility).
  external js.JSPromise rm(String path, [JsFsRmOptions? options]);

  /// fsPromises.rmdir(path[, options])#
  /// History
  /// path <string> | <Buffer> | <URL>
  /// options <Object>
  /// maxRetries <integer> If an EBUSY, EMFILE, ENFILE, ENOTEMPTY, or EPERM error is encountered, Node.js retries the operation with a linear backoff wait of retryDelay milliseconds longer on each try. This option represents the number of retries. This option is ignored if the recursive option is not true. Default: 0.
  /// recursive <boolean> If true, perform a recursive directory removal. In recursive mode, operations are retried on failure. Default: false. Deprecated.
  /// retryDelay <integer> The amount of time in milliseconds to wait between retries. This option is ignored if the recursive option is not true. Default: 100.
  /// err <Error>
  /// Asynchronous rmdir(2). No arguments other than a possible exception are given to the completion callback.
  /// sing fs.rmdir() on a file (not a directory) results in an ENOENT error on Windows and an ENOTDIR error on POSIX.
  /// To get a behavior similar to the rm -rf Unix command, use fs.rm() with options { recursive: true, force: true }.
  @Deprecated('use rm')
  external js.JSPromise rmdir(String path, [JsFsRmOptions? options]);

  /// fsPromises.mkdir(path[, options])#
  /// Added in: v10.0.0
  /// path <string> | <Buffer> | <URL>
  /// options <Object> | <integer>
  /// recursive <boolean> Default: false
  /// mode <string> | <integer> Not supported on Windows. Default: 0o777.
  /// Returns: <Promise> Upon success, fulfills with undefined if recursive is false, or the first directory path created if recursive is true.
  /// Asynchronously creates a directory.
  ///
  /// The optional options argument can be an integer specifying mode (permission and sticky bits), or an object with a mode property and a recursive property indicating whether parent directories should be created. Calling fsPromises.mkdir() when path is a directory that exists results in a rejection only when recursive is false.
  external js.JSPromise mkdir(String path, [JsFsMkdirOptions? options]);

  /// fsPromises.lstat(path[, options])#
  /// History
  /// Version	Changes
  /// v10.5.0
  /// Accepts an additional options object to specify whether the numeric values returned should be bigint.
  ///
  /// v10.0.0
  /// Added in: v10.0.0
  ///
  /// path <string> | <Buffer> | <URL>
  /// options <Object>
  /// bigint <boolean> Whether the numeric values in the returned <fs.Stats> object should be bigint. Default: false.
  /// Returns: <Promise> Fulfills with the <fs.Stats> object for the given path.
  external js.JSPromise<JsFsStats> lstat(String path);

  /// fsPromises.rename(oldPath, newPath)#
  /// Added in: v10.0.0
  /// oldPath <string> | <Buffer> | <URL>
  /// newPath <string> | <Buffer> | <URL>
  /// Returns: <Promise> Fulfills with undefined upon success.
  /// Renames oldPath to newPath.
  external js.JSPromise rename(String oldPath, String newPath);

  /// fsPromises.readdir(path[, options])#
  /// History
  /// path <string> | <Buffer> | <URL>
  /// options <string> | <Object>
  /// encoding <string> Default: 'utf8'
  /// withFileTypes <boolean> Default: false
  /// recursive <boolean> If true, reads the contents of a directory recursively. In recursive mode, it will list all files, sub files, and directories. Default: false.
  /// Returns: <Promise> Fulfills with an array of the names of the files in the directory excluding '.' and '..'.
  /// Reads the contents of a directory.
  ///
  /// The optional options argument can be a string specifying an encoding, or an object with an encoding property specifying the character encoding to use for the filenames. If the encoding is set to 'buffer', the filenames returned will be passed as <Buffer> objects.
  ///
  /// If options.withFileTypes is set to true, the returned array will contain <fs.Dirent> objects.
  external js.JSPromise<js.JSArray<js.JSString>> readdir(String path,
      [JsFsReaddirOptions options]);
  @js.JS('appendFile')
  external js.JSPromise appendFileBytes(String path, js.JSUint8Array bytes);

  @js.JS('writeFile')
  external js.JSPromise writeFileBytes(String path, js.JSUint8Array bytes);

  @js.JS('readFile')
  external js.JSPromise<js.JSUint8Array> readFileBytes(String path);

  /// fsPromises.cp(src, dest[, options])#
  /// History
  /// src <string> | <URL> source path to copy.
  /// dest <string> | <URL> destination path to copy to.
  /// options <Object>
  /// dereference <boolean> dereference symlinks. Default: false.
  /// errorOnExist <boolean> when force is false, and the destination exists, throw an error. Default: false.
  /// filter <Function> Function to filter copied files/directories. Return true to copy the item, false to ignore it. When ignoring a directory, all of its contents will be skipped as well. Can also return a Promise that resolves to true or false Default: undefined.
  /// src <string> source path to copy.
  /// dest <string> destination path to copy to.
  /// Returns: <boolean> | <Promise>
  /// force <boolean> overwrite existing file or directory. The copy operation will ignore errors if you set this to false and the destination exists. Use the errorOnExist option to change this behavior. Default: true.
  /// mode <integer> modifiers for copy operation. Default: 0. See mode flag of fsPromises.copyFile().
  /// preserveTimestamps <boolean> When true timestamps from src will be preserved. Default: false.
  /// recursive <boolean> copy directories recursively Default: false
  /// verbatimSymlinks <boolean> When true, path resolution for symlinks will be skipped. Default: false
  /// Returns: <Promise> Fulfills with undefined upon success.
  /// Asynchronously copies the entire directory structure from src to dest, including subdirectories and files.
  ///
  /// When copying a directory to another directory, globs are not supported and behavior is similar to cp dir1/ dir2/.
  external js.JSPromise cp(String src, String dest, [JsFsCopyOptions? options]);
}

extension type JsFsRmOptions._(js.JSObject _) implements js.JSObject {
  external JsFsRmOptions({bool? recursive, bool? force});
}
extension type JsFsMkdirOptions._(js.JSObject _) implements js.JSObject {
  external JsFsMkdirOptions({bool? recursive});
}

extension type JsFsReaddirOptions._(js.JSObject _) implements js.JSObject {
  external JsFsReaddirOptions({bool? recursive});
}

extension type JsFsCopyOptions._(js.JSObject _) implements js.JSObject {
  external JsFsCopyOptions({bool? recursive});
}

extension type JsFsStats._(js.JSObject _) implements js.JSObject {
  // {dev: 66311, mode: 16893, nlink: 2, uid: 1000, gid: 1000, rdev: 0, blksize: 4096, ino: 49676304, size: 4096, blocks: 8, atimeMs: 1718626106862.2302, mtimeMs: 1718626106862.2302, ctimeMs: 1718626106862.2302, birthtimeMs: 1718626106862.2302, atime: {}, mtime: {}, ctime: {}, birthtime: {}}
  external int get mode;
  external int get size;
  external num get mtimeMs;
  external js.JSDate get mtime;
}

extension JsFsStatsExt on JsFsStats {
  /// stats.isDirectory()#
  /// Added in: v0.1.10
  /// Returns: <boolean>
  /// Returns true if the <fs.Stats> object describes a file system directory.
  external bool isDirectory();

  /// stats.isFile()#
  /// Added in: v0.1.10
  /// Returns: <boolean>
  /// Returns true if the <fs.Stats> object describes a regular file.
  external bool isFile();

  /// stats.isSymbolicLink()#
  /// Added in: v0.1.10
  /// Returns: <boolean>
  /// Returns true if the <fs.Stats> object describes a symbolic link.
  /// This method is only valid when using fs.lstat().
  external bool isSymbolicLink();
}

extension type JsFsError._(js.JSObject _) implements js.JSObject {}

extension JsFsErrorExt on JsFsError {
  external int? get errno;
  external String? get code;
  external String? get path;
  external String? get message;
}

// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js' as js;

import 'package:fs_shim/fs.dart' as fs_shim;
import 'package:node_interop/fs.dart';
import 'package:node_interop/path.dart' as node_path;

import 'directory.dart';
import 'platform.dart';

final _notFoundDateTime = DateTime.fromMillisecondsSinceEpoch(0);

abstract class FileSystemEntity {
  static final RegExp _absoluteWindowsPathPattern =
      RegExp(r'^(\\\\|[a-zA-Z]:[/\\])');

  String get path;

  bool get isAbsolute => node_path.path.isAbsolute(path);

  @override
  String toString() => "$runtimeType: '$path'";

  static final RegExp _parentRegExp = Platform.isWindows
      ? RegExp(r'[^/\\][/\\]+[^/\\]')
      : RegExp(r'[^/]/+[^/]');

  static String parentOf(String path) {
    var rootEnd = -1;
    if (Platform.isWindows) {
      if (path.startsWith(_absoluteWindowsPathPattern)) {
        // Root ends at first / or \ after the first two characters.
        rootEnd = path.indexOf(RegExp(r'[/\\]'), 2);
        if (rootEnd == -1) return path;
      } else if (path.startsWith('\\') || path.startsWith('/')) {
        rootEnd = 0;
      }
    } else if (path.startsWith('/')) {
      rootEnd = 0;
    }
    // Ignore trailing slashes.
    // All non-trivial cases have separators between two non-separators.
    var pos = path.lastIndexOf(_parentRegExp);
    if (pos > rootEnd) {
      return path.substring(0, pos + 1);
    } else if (rootEnd > -1) {
      return path.substring(0, rootEnd + 1);
    } else {
      return '.';
    }
  }

  Directory get parent => Directory(parentOf(path));

  Future<String> resolveSymbolicLinks() {
    var completer = Completer<String>();
    void callback(Object? err, String? resolvedPath) {
      if (err == null) {
        completer.complete(resolvedPath as String);
      } else {
        completer.completeError(err);
      }
    }

    var jsCallback = js.allowInterop(callback);

    fs.realpath(path, jsCallback);
    return completer.future;
  }

  Future<FileStat> stat() => FileStat.stat(path);

  Future<FileSystemEntity> delete({bool recursive = false});
}

/// A FileStat object represents the result of calling the POSIX stat() function
/// on a file system object.  It is an immutable object, representing the
/// snapshotted values returned by the stat() call.
class FileStat {
  final DateTime changed;

  final DateTime modified;

  final DateTime accessed;

  final fs_shim.FileSystemEntityType type;

  final int mode;

  final int size;

  FileStat._internal(this.changed, this.modified, this.accessed, this.type,
      this.mode, this.size);

  FileStat.notFound()
      : changed = _notFoundDateTime,
        modified = _notFoundDateTime,
        accessed = _notFoundDateTime,
        type = fs_shim.FileSystemEntityType.notFound,
        mode = 0,
        size = -1;

  factory FileStat._fromNodeStats(Stats stats) {
    var type = fs_shim.FileSystemEntityType.notFound;
    if (stats.isDirectory()) {
      type = fs_shim.FileSystemEntityType.directory;
    } else if (stats.isFile()) {
      type = fs_shim.FileSystemEntityType.file;
    } else if (stats.isSymbolicLink()) {
      type = fs_shim.FileSystemEntityType.link;
    }
    return FileStat._internal(
      DateTime.parse(stats.ctime.toISOString()),
      DateTime.parse(stats.mtime.toISOString()),
      DateTime.parse(stats.atime.toISOString()),
      type,
      stats.mode.round(),
      stats.size,
    );
  }

  /// Asynchronously calls the operating system's stat() function on [path].
  ///
  /// Returns a Future which completes with a [FileStat] object containing
  /// the data returned by stat(). If the call fails, completes the future with a
  /// [FileStat] object with `.type` set to FileSystemEntityType.notFound and
  /// the other fields invalid.
  static Future<FileStat> stat(String? path) {
    var completer = Completer<FileStat>();

    // stats has to be an optional param despite what the documentation says...
    void callback(Object? err, [Object? stats]) {
      if (err == null) {
        completer.complete(FileStat._fromNodeStats(stats as Stats));
      } else {
        completer.complete(FileStat.notFound());
      }
    }

    var jsCallback = js.allowInterop(callback);
    fs.lstat(path, jsCallback);
    return completer.future;
  }

  /// Calls the operating system's stat() function on [path].
  ///
  /// Returns a [FileStat] object containing the data returned by stat().
  /// If the call fails, returns a [FileStat] object with .type set to
  /// FileSystemEntityType.notFound and the other fields invalid.
  static FileStat statSync(String path) {
    try {
      return FileStat._fromNodeStats(fs.lstatSync(path));
    } catch (_) {
      return FileStat.notFound();
    }
  }

  String modeString() {
    var permissions = mode & 0xFFF;
    var codes = const ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'];
    var result = <String>[];
    if ((permissions & 0x800) != 0) result.add('(suid) ');
    if ((permissions & 0x400) != 0) result.add('(guid) ');
    if ((permissions & 0x200) != 0) result.add('(sticky) ');
    result
      ..add(codes[(permissions >> 6) & 0x7])
      ..add(codes[(permissions >> 3) & 0x7])
      ..add(codes[permissions & 0x7]);
    return result.join();
  }

  @override
  String toString() => '''
FileStat: type $type
          changed $changed
          modified $modified
          accessed $accessed
          mode ${modeString()}
          size $size''';
}

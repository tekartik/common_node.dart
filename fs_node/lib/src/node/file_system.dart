// Copyright (c) 2020, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:fs_shim/fs.dart' as fs_shim;
import 'package:node_interop/fs.dart';
import 'package:node_interop/util.dart';

/// A [FileSystem] implementation backed by Node.js's `fs` module.
class NodeFileSystem {
  const NodeFileSystem();

  Future<fs_shim.FileSystemEntityType> type(String path,
      {bool followLinks = true}) async {
    Stats stats;
    try {
      stats = await invokeAsync1(followLinks ? fs.stat : fs.lstat, path);
    } catch (_) {
      return fs_shim.FileSystemEntityType.notFound;
    }

    if (stats.isDirectory()) return fs_shim.FileSystemEntityType.directory;
    if (stats.isFile()) return fs_shim.FileSystemEntityType.file;
    if (stats.isSymbolicLink()) return fs_shim.FileSystemEntityType.link;
    return fs_shim.FileSystemEntityType.notFound;
  }
}

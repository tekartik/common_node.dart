@TestOn('node')
// Copyright (c) 2015, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library;

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_test/fs_test.dart';

import 'test_common_node.dart';

void main() {
  var fileSystemContext = FileSystemTestContextNode('fs_node');
  FileSystem fs = fileSystemContext.fs;

  group('fs_node', () {
    test('basics', () {
      expect(fs.supportsFileLink, isFalse);
      expect(fs.supportsLink, isFalse);
      expect(fs.supportsRandomAccess, isFalse);
    });

    test('name', () {
      expect(fs.name, 'node_io');
    }); /*
    test('equals', () {
      // Files cannot be compared!
      expect(node.File('test'), isNot(node.File('test')));
      expect(node.Directory('test'), isNot(node.Directory('test')));
    });
    test('type', () async {
      expect(await fs.type(join('pubspec.yaml')), FileSystemEntityType.file);
      expect(await fs.type('.'), FileSystemEntityType.directory);
    });
    test('test_path', () async {
      expect(fileSystemContext.outPath,
          endsWith(join('.dart_tool', 'tekartik_fs_node', 'test', 'fs')));
    });

    group('conversion', () {
      test('file', () {
        final ioFile = node.File('file');
        File file = wrapIoFile(ioFile);
        expect(unwrapIoFile(file), ioFile);
      });
      test('dir', () {
        final ioDirectory = node.Directory('dir');
        Directory dir = wrapIoDirectory(ioDirectory);
        expect(unwrapIoDirectory(dir), ioDirectory);
      });
      /*
      test('link', () {
        Link ioLink = new Link('link');
        Link link = wrapIoLink(ioLink);
        expect(unwrapIoLink(link), ioLink);
      });
      */

      test('filesystementity', () {
        node.FileSystemEntity ioFse;
        FileSystemEntityNode fse;
        /*
        FileSystemEntity ioFse = new Link('link');
        FileSystemEntity fse = wrapIoLink(ioFse as Link);
        expect(ioFse.path, fse.path);
        */

        ioFse = node.Directory('dir');
        fse = wrapIoDirectory(ioFse as node.Directory);
        expect(fse.nativeInstance, ioFse);

        ioFse = node.File('file');
        fse = wrapIoFile(ioFse as node.File);
        expect(fse.nativeInstance, ioFse);
      });

      test('oserror', () {
        const ioOSError = node.NodeOSError(message: 'test');
        OSError osError = wrapIoOSError(ioOSError);
        expect(unwrapIoOSError(osError), ioOSError);
      });

      test('filestat', () async {
        final ioFileStat = await node.Directory.current.stat();
        FileStat fileStat = wrapIoFileStat(ioFileStat);
        expect(unwrapIoFileStat(fileStat), ioFileStat);
      });

      /*
      test('filesystemexception', () {
        const ioFileSystemException = FileSystemException();
        final fileSystemException =
            wrapIoFileSystemException(ioFileSystemException);
        expect(unwrapIoFileSystemException(fileSystemException),
            ioFileSystemException);
      });
      
       */

      test('filemode', () async {
        var ioFileMode = node.FileMode.read;
        var fileMode = wrapIoFileMode(ioFileMode);
        expect(unwrapIoFileMode(fileMode), ioFileMode);

        ioFileMode = node.FileMode.write;
        fileMode = wrapIoFileMode(ioFileMode);
        expect(unwrapIoFileMode(fileMode), ioFileMode);

        ioFileMode = node.FileMode.append;
        fileMode = wrapIoFileMode(ioFileMode);
        expect(unwrapIoFileMode(fileMode), ioFileMode);
      });

      test('fileentitytype', () async {
        var ioFset = node.FileSystemEntityType.notFound;
        var fset = wrapIoFileSystemEntityType(ioFset);
        expect(unwrapIoFileSystemEntityType(fset), ioFset);

        ioFset = node.FileSystemEntityType.file;
        fset = wrapIoFileSystemEntityType(ioFset);
        expect(unwrapIoFileSystemEntityType(fset), ioFset);

        ioFset = node.FileSystemEntityType.directory;
        fset = wrapIoFileSystemEntityType(ioFset);
        expect(unwrapIoFileSystemEntityType(fset), ioFset);

        ioFset = node.FileSystemEntityType.link;
        fset = wrapIoFileSystemEntityType(ioFset);
        expect(unwrapIoFileSystemEntityType(fset), ioFset);
      });
    });
    */

    // All tests
    defineTests(fileSystemContext);
  });
}

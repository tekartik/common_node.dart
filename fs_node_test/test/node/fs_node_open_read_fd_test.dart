@TestOn('node')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:fs_shim/fs.dart';
import 'package:tekartik_fs_node/src/node/fs_node_js_interop.dart';

import 'test_common_node.dart';

/// openRead must release its file descriptor (it leaked one per call).
void main() {
  var fileSystemContext = FileSystemTestContextNode('fs_node_open_read_fd');
  var fs = fileSystemContext.fs;
  var p = fs.path;
  // Linux only: /proc/self/fd lists the open file descriptors of node.
  var isLinux = (fileSystemContext.platform as PlatformContextNode).isIoLinux;

  Future<int> fdCount() async =>
      (await fs.nativeInstance.readdir('/proc/self/fd').toDart).length;

  // The old code leaked one per read, 20 here; leave room for node itself.
  var leakMax = 4;

  /// The handle of a cancelled read is closed once its pending read completes.
  Future<int> fdCountSettled(int before) async {
    var sw = Stopwatch()..start();
    while (true) {
      var count = await fdCount();
      if (count - before <= leakMax ||
          sw.elapsed > const Duration(seconds: 5)) {
        return count;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  group('open_read_fd', () {
    late File file;
    // More than one 64KB chunk.
    var content = Uint8List.fromList(
      List<int>.generate(150 * 1024, (i) => i % 256),
    );
    setUpAll(() async {
      var dir = await fileSystemContext.prepare();
      file = fs.file(p.join(dir.path, 'file.bin'));
      await file.writeAsBytes(content);
    });

    test('read all', () async {
      var before = await fdCount();
      for (var i = 0; i < 20; i++) {
        var bytes = (await file.openRead().toList()).expand((List<int> e) => e);
        expect(bytes.length, content.length);
      }
      expect(await fdCount() - before, lessThanOrEqualTo(leakMax));
    });

    test('read range', () async {
      var before = await fdCount();
      for (var i = 0; i < 20; i++) {
        var bytes = (await file.openRead(10, 70000).toList()).expand(
          (List<int> e) => e,
        );
        // Deep compare once only: its garbage lets GC close leaked handles.
        if (i == 0) {
          expect(bytes, content.sublist(10, 70000));
        } else {
          expect(bytes.length, 70000 - 10);
        }
      }
      expect(await fdCount() - before, lessThanOrEqualTo(leakMax));
    });

    test('cancel', () async {
      var before = await fdCount();
      for (var i = 0; i < 20; i++) {
        expect((await file.openRead().first).length, 64 * 1024);
      }
      expect(await fdCountSettled(before) - before, lessThanOrEqualTo(leakMax));
    });

    test('missing file', () async {
      var before = await fdCount();
      for (var i = 0; i < 5; i++) {
        await expectLater(
          fs.file(p.join(file.parent.path, 'missing.bin')).openRead().toList(),
          throwsA(isA<FileSystemException>()),
        );
      }
      expect(await fdCount() - before, lessThanOrEqualTo(leakMax));
    });
  }, skip: isLinux ? false : 'linux only');
}

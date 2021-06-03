import 'package:tekartik_fs_test/fs_test.dart';
import 'package:tekartik_fs_test/test_common.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    defineTests(memoryFileSystemTestContext);
  });
}

import 'package:tekartik_fs_node/fs_node_universal.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

void main() {
  test('separator', () {
    var fs = fileSystemUniversal;

    var p = fs.path;
    if (platform.isWindows) {
      expect(p.separator, '\\');
    } else {
      expect(p.separator, '/');
    }
  });
}

import 'package:tekartik_fs_node/fs_node_universal.dart';
import 'package:test/test.dart';

void main() {
  test('universal', () async {
    var file = fs.file('pubspec.yaml');
    var dir = fs.directory('test');
    expect(await dir.exists(), isTrue);
    expect(await file.exists(), isTrue);
  });
}

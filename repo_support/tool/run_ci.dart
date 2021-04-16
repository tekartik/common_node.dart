import 'package:path/path.dart';
import 'package:tekartik_build_node/package.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in [
    'platform_node',
    'platform_node_test',
    'http_redirect_node',
    'fs_node',
    'fs_node_test',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path);
  }

  // TODO fix tests
  for (var dir in [
    'http_node',
    'http_node_test',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path, NodePackageRunCiOptions(noNodeTest: true));
  }
}

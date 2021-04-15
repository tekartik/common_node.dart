import 'package:path/path.dart';
import 'package:tekartik_app_node_build/package.dart';

var topDir = '..';

Future<void> main() async {
  /* temp nnbd
  for (var dir in [
    'fs_node',
    'http_node',
    'http_redirect_node',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path, NodePackageRunCiOptions(noNodeTest: true));
  }
  */
  for (var dir in [
    'platform_node',
    'platform_node_test',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path);
  }
}

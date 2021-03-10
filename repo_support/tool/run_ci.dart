import 'package:path/path.dart';
import 'package:tekartik_app_node_build/package.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in [
    // 'fs_node', temp
    'http_node',
    'platform_node',
    'http_redirect_node',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path);
  }
}

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_build_node/package.dart';

bool get runningOnGithub => Platform.environment['GITHUB_ACTIONS'] == 'true';
var topDir = '..';

Future<void> main() async {
  for (var dir in [
    'core_node',
    'platform_node',
    'platform_node_test',
    'fs_node',
    'fs_node_test',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path);
  }

  for (var dir in [
    'http_node',
    'http_node_test',
  ]) {
    var path = join(topDir, dir);

    await nodePackageRunCi(
        path, NodePackageRunCiOptions(noNodeTest: true)); //runningOnGithub));
  }
}

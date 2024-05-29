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
    'http_node_test',
  ]) {
    var path = join(topDir, dir);
    await nodePackageRunCi(path);
  }

  // TODO fix tests
  for (var dir in [
    'http_redirect_node',
  ]) {
    var path = join(topDir, dir);

    await nodePackageRunCi(path, NodePackageRunCiOptions(noNodeTest: true));
  }

  for (var dir in [
    'http_node',
  ]) {
    var path = join(topDir, dir);

    await nodePackageRunCi(
        path, NodePackageRunCiOptions(noNodeTest: true)); //runningOnGithub));
  }
}

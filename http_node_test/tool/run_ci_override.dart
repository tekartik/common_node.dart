import 'dart:io';

import 'package:tekartik_build_node/package.dart';

bool get runningOnGithub => Platform.environment['GITHUB_ACTIONS'] == 'true';

Future main() async {
  await nodePackageRunCi('.',
      NodePackageRunCiOptions(noNodeTest: runningOnGithub, noOverride: true));
}

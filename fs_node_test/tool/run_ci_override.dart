import 'package:tekartik_build_node/package.dart';

Future main() async {
  await nodePackageRunCi(
      '.', NodePackageRunCiOptions(noNodeTest: true, noOverride: true));
}

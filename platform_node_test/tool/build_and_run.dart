import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  await nodePackageCompileJs('.', input: 'node/main.dart');
  await nodePackageRun('.');
}

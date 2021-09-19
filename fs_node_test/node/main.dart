import 'package:tekartik_fs_node/fs_node.dart';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  var fs = fileSystemNode;
  var content = await fs.file('pubspec.yaml').readAsString();
  var map = loadYaml(content) as Map;
  print(map.keys);
}

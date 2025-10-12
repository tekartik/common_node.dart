import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_stdio_node/src/stdio_node_interop.dart';

Future<void> main() async {
  /*var fs = fileSystemNode;
  var content = await fs.file('pubspec.yaml').readAsString();
  var map = loadYaml(content) as Map;
  print(map.keys);

   */
  //var rl = jsReadlineModule.createInterface(jsStdin, jsStdout);

  print('hello');
  var rl = jsReadlineModule.createInterface(jsStdin, jsStdout);
  var answer = await rl.question('What do you think of Node.js? ').toDart;
  print(answer.keys());
  print(jsAnyDebugRuntimeType(answer));
  print(answer.getOwnPropertyNames());
  print('answer: $answer');
  rl.close();
  //  console.log(`Thank you for your valuable feedback: ${answer}`);
}

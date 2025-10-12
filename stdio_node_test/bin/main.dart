import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

Future<void> main() async {
  print('hello');
  var rl = readline;
  var answer = await rl.question('What do you think of Node.js? ');
  print('answer: $answer');
  rl.close();
  print('closed');
  process.exit(0);
}

---
name: tekartik-stdio-node-setup
description: >-
  Use when a Dart command line program compiled for Node.js (and optionally
  run on the Dart VM too) needs to prompt the user on stdin/stdout with
  tekartik_stdio_node: readline.question(prompt), the Readline interface,
  readline.close(), the readline.dart import (node:readline/promises on
  node, process_run sharedStdIn with dart:io), the re-exported process
  (process.exit, process.cwd) from process.dart, ending an interactive node
  program, and testing prompt logic with a scripted Readline.
---

# tekartik_stdio_node: readline prompts on Node.js (tekartik_stdio_node)

`tekartik_stdio_node` gives Dart code a single `readline` object to ask
questions on the terminal, implemented with `node:readline/promises` when the
code is compiled to JavaScript for Node.js and with `dart:io` (through
`process_run`'s `sharedStdIn`) on the VM. It re-exports `process` from
`tekartik_core_node` so a console program can exit cleanly.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_stdio_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: stdio_node
    tekartik_core_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: core_node
  ```
  `tekartik_core_node` is only needed explicitly for `console`
  (`package:tekartik_core_node/console.dart`).
* Imports: `package:tekartik_stdio_node/readline.dart` exports `readline` (a
  `Readline`) with `Future<String> question(String prompt)` and
  `void close()`; `package:tekartik_stdio_node/process.dart` re-exports
  `package:tekartik_core_node/process.dart` (`process`, `Process`, with
  `exit(int code)` and `cwd()`).
* Implementation is picked by conditional import on
  `dart.library.js_interop`: on node `readline` wraps one
  `node:readline/promises` interface created over `process.stdin` /
  `process.stdout` on first use; on the VM `question` writes the prompt to
  `stdout` and awaits `sharedStdIn.nextLine()`. It is not usable in a
  browser.
* `question(prompt)` prints the prompt as is (add the trailing space
  yourself) and resolves with the typed line without its newline. Await each
  question before asking the next one.
* Ending the program: on node `close()` is a no-op and the readline
  interface keeps stdin open, so node does not exit by itself: call
  `process.exit(0)` when done. On the VM `close()` terminates
  `sharedStdIn`; `process.exit` works there too, so one `main` serves both.
* Output: `print` or `console.out.writeln` from `tekartik_core_node`; on node
  the prompt itself is written by the readline interface.
* Tests: prompts cannot run under `dart test`; keep `readline` calls in the
  entry point (`bin/main.dart` or a `node/` script) and test the logic by
  injecting a `Readline` implementation with scripted answers. `process` is
  accessible on every platform (`dart test -p vm,node`).
* Running on node: compile the entry point with dart2js
  (`dart compile js -o build/main.js bin/main.dart` then
  `node build/main.js`); the repo's `stdio_node_test` package uses
  `tekartik_build_node` for that.

## Examples

### Ask one question and exit

```dart
import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

Future<void> main() async {
  var answer = await readline.question('What do you think of Node.js? ');
  print('answer: $answer');
  readline.close();
  process.exit(0);
}
```

### Command loop with console output

```dart
import 'package:tekartik_core_node/console.dart';
import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

Future<void> main() async {
  console.out.writeln('type a command, empty line or "exit" to quit');
  while (true) {
    var line = (await readline.question('> ')).trim();
    if (line.isEmpty || line == 'exit') {
      break;
    }
    console.out.writeln('running $line in ${process.cwd()}');
  }
  readline.close();
  process.exit(0);
}
```

### Test prompt logic with a scripted Readline

```dart
import 'package:tekartik_stdio_node/readline.dart';
import 'package:test/test.dart';

class ScriptedReadline implements Readline {
  final List<String> answers;
  final prompts = <String>[];

  ScriptedReadline(this.answers);

  @override
  Future<String> question(String prompt) async {
    prompts.add(prompt);
    return answers.removeAt(0);
  }

  @override
  void close() {}
}

Future<String> askName(Readline rl) async {
  var name = await rl.question('name? ');
  return name.isEmpty ? 'anonymous' : name;
}

void main() {
  test('askName', () async {
    expect(await askName(ScriptedReadline([''])), 'anonymous');
    var rl = ScriptedReadline(['alex']);
    expect(await askName(rl), 'alex');
    expect(rl.prompts, ['name? ']);
  });
}
```

## Common mistakes

* Forgetting `process.exit(0)`: the node program hangs after the last
  answer.
* Calling `readline.question` from a browser build.
* Issuing several `question` calls concurrently instead of awaiting each.

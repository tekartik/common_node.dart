# tekartik_stdio_node

Ask questions on the terminal from a Dart program compiled to JavaScript for
Node.js (dart2js), or run on the Dart VM: one `readline` object
(`question(prompt)`, `close()`), on `node:readline/promises` on node and on
process_run's `sharedStdIn` on the VM. It also re-exports `process` of
[tekartik_core_node](../core_node) (`exit`, `cwd`).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_stdio_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: stdio_node
```

```dart
import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

Future<void> main() async {
  var name = await readline.question('Your name? ');
  print('Hello $name');
  readline.close();
  process.exit(0);
}
```

Run it on the VM with `dart run`, or on node after a dart2js build with the
node preamble ([tekartik_build_node](https://github.com/tekartik/build_node.dart)).

## Platforms

* node: `question` uses one readline interface over `process.stdin` /
  `process.stdout`, created on first use; `close()` closes it (a later
  `question` creates a new one).
* Dart VM: `question` writes the prompt to `stdout` and reads a line from
  `sharedStdIn`; `close()` terminates `sharedStdIn` so that the program can
  exit. A second `close()` does nothing; stdin cannot be read again after it.
* Browser: not supported.

## Common pitfalls

* Await each `question` before asking the next one.
* Call `readline.close()` (and `process.exit(0)` on node) when done: an open
  interface keeps the program running.
* Prompts cannot run under `dart test`: test the logic with a `Readline` of
  your own returning scripted answers.

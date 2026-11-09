# tekartik_core_node

Node.js basics for Dart compiled to JavaScript (`dart:js_interop`): `console`,
`process`, `require` and `exports`. `console` and `process` fall back to
`dart:io` on the Dart VM, so a script can run on node and on the VM. It is the
lowest layer of this repo (fs_node, platform_node, stdio_node, http_node).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_core_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: core_node
```

```dart
import 'package:tekartik_core_node/console.dart';
import 'package:tekartik_core_node/process.dart';

void main() {
  console.out.writeln('cwd: ${process.cwd()}');
  if (process.cwd().isEmpty) {
    console.err.writeln('no current directory');
    process.exit(1);
  }
}
```

Run it on the VM (`dart run`), or compile it for node with the node preamble
of [tekartik_build_node](https://github.com/tekartik/build_node.dart)
(`nodePackageCompileJs`, or `nodedev build`), then
`node build/node/main.dart.js`.

## Libraries and platforms

| Import | What | node | Dart VM, Flutter native |
|---|---|---|---|
| `console.dart` | `console.out` / `console.err` `writeln` | `console.log` / `console.error` | `stdout` / `stderr` |
| `process.dart` | `process.exit(code)`, `process.cwd()` | node `process` | `dart:io` |
| `require.dart` | `require<T extends JSObject>('node:os')` | yes | no |
| `exports.dart` | `exports` of a CommonJS module (`setProperty`) | yes | no |

Bind a module with an extension type and keep it in a top level `final`:

```dart
import 'dart:js_interop';

import 'package:tekartik_core_node/require.dart';

extension type JsOs._(JSObject _) implements JSObject {
  external String platform();
}

final jsOs = require<JsOs>('node:os');

void main() {
  print(jsOs.platform()); // linux
}
```

## Common pitfalls

* `require` and `exports` only work when node runs the compiled JavaScript
  with the node preamble (tekartik_build_node, `dart test -p node`): a plain
  `dart compile js` output fails with `require is not a function`. Keep them
  in node only code or `@TestOn('node')` tests (node on the PATH).
* On node `main` receives no arguments (dart2js does not pass
  `process.argv`).
* In a browser build the node branch is compiled too: `console` writes to the
  browser console, `process` fails (no `process` global).
* On node `writeln(obj)` passes `obj.jsify()` to `console.log`: a Dart map or
  list prints as a JS object, any other object is not printed through its
  `toString()`; pass a string (`'$obj'`) when the text matters.
* A missing module makes `require` throw the JS error object (a `JSObject`),
  not a Dart exception.

Agent skill: [skills/tekartik-core-node-setup](skills/tekartik-core-node-setup/SKILL.md).

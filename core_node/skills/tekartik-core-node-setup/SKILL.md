---
name: tekartik-core-node-setup
description: >-
  Use when Dart code compiled to JavaScript for Node.js needs the basic node
  primitives of tekartik_core_node: console (console.out / console.err
  writeln, Console, ConsoleSink), process (process.exit, process.cwd,
  Process), require<T>(module) to load a node module as a dart:js_interop
  extension type, and exports (JSExports) to expose values from a compiled
  module (firebase functions style index). Also covers the dart:io and no-op
  fallbacks of console and process, the console.dart / process.dart /
  require.dart / exports.dart imports and running @TestOn('node') tests with
  dart test -p node.
---

# tekartik_core_node: console, process, require and exports (tekartik_core_node)

`tekartik_core_node` is the lowest layer of the `common_node.dart` repo: four
tiny libraries wrapping Node.js globals through `dart:js_interop`, with
`dart:io` fallbacks for `console` and `process` so the same code also runs as
a Dart VM script. The other node packages of the repo (`tekartik_fs_node`,
`tekartik_platform_node`, `tekartik_stdio_node`, `tekartik_http_node`) are
built on its `require`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_core_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: core_node
  ```
* Four entry points, import only what you need:
  * `package:tekartik_core_node/console.dart`: `console`, a `Console` with
    `out` and `err` sinks (`ConsoleSink`, `writeln([Object? obj = ''])`).
  * `package:tekartik_core_node/process.dart`: `process`, a `Process` with
    `exit(int code)` and `String cwd()`.
  * `package:tekartik_core_node/require.dart`:
    `T require<T extends JSObject>(String module)`.
  * `package:tekartik_core_node/exports.dart`: `exports`, a `JSExports`
    (an extension type on `JSObject`).
* Platform resolution (conditional imports, checked in this order): with
  `dart.library.js_interop` (dart2js/ddc output, i.e. a node build)
  `console.out` / `console.err` call `console.log` / `console.error` and
  `process` is the node `process` global; with `dart.library.io` (VM,
  Flutter native) `console` writes to `stdout` / `stderr` and `process`
  uses `dart:io` `exit` and `Directory.current.path`; anywhere else
  `console` is silent, `process.exit` is a no-op and `process.cwd()` throws
  `UnimplementedError`. `console` and `process` are therefore safe in
  shared code.
* `require` and `exports` are node only: importing them is harmless
  everywhere, calling them only works when the JS is executed by Node.js
  (they bind the `require` and `exports` globals of a CommonJS module). Keep
  them in node-only files or `@TestOn('node')` tests, or guard with
  `isRunningInNode` from `tekartik_platform_node/context_node.dart`.
* `require<T>(module)`: declare an `extension type` on `JSObject` with
  `external` members for the module and pass it as `T`; the repo uses the
  `'node:fs/promises'`, `'node:os'`, `'node:readline/promises'` module names.
  Store the result in a top-level `final` so the module is required once. A
  missing module throws the JS error object (a `JSObject`), not a Dart
  exception.
* `console.out.writeln(obj)` on node passes `obj?.jsify()` to `console.log`:
  strings and numbers print as is, Dart maps and lists become JS objects and
  arrays. Interpolate into a string when the text matters.
* `exports`: set entries with `dart:js_interop_unsafe`
  `setProperty('name'.toJS, value)` (a `.toJS` string, number or function):
  this is how a compiled `index.dart` exposes its functions to node. Reading
  it back as a Dart map is possible with `jsObjectAsMap` from
  `tekartik_js_utils_interop/js_converter.dart`.
* `process.exit(code)` ends the node process immediately; interactive
  programs (a `readline` interface from `tekartik_stdio_node`) need it, since
  an open stdin keeps node alive.
* Tests: node-only tests are tagged `@TestOn('node')` and run with
  `dart test -p node` (needs `node` on the PATH, compiles with dart2js);
  `dart test -p vm,node` runs both platforms. Keep a trivial vm test file
  when the package is also run with plain `dart test`.

## Examples

### Command-line script that works on node and on the VM

```dart
import 'package:tekartik_core_node/console.dart';
import 'package:tekartik_core_node/process.dart';

void main(List<String> args) {
  console.out.writeln('cwd: ${process.cwd()}');
  if (args.isEmpty) {
    console.err.writeln('missing argument');
    process.exit(1);
  }
  console.out.writeln('hello ${args.first}');
}
```

### Bind a node module with require

```dart
import 'dart:js_interop';

import 'package:tekartik_core_node/require.dart';

/// Minimal binding of the node `os` module.
extension type JsOs._(JSObject _) implements JSObject {
  external String platform();
  external String hostname();
  external JSArray<JSAny> cpus();
}

final jsOs = require<JsOs>('node:os');

void main() {
  print('${jsOs.platform()} ${jsOs.hostname()} ${jsOs.cpus().toDart.length} cpus');
}
```

### Expose values from a compiled module (index.dart)

```dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_core_node/exports.dart';

String hello(String name) => 'hello $name';

void main() {
  // `require('./index.js').version` and `.hello('world')` in node
  exports.setProperty('version'.toJS, '1.0.0'.toJS);
  exports.setProperty('hello'.toJS, hello.toJS);
}
```

### Node-only test

```dart
@TestOn('node')
library;

import 'dart:js_interop';

import 'package:tekartik_core_node/process.dart';
import 'package:tekartik_core_node/require.dart';
import 'package:test/test.dart';

void main() {
  test('process and require', () {
    expect(process.cwd(), isNotEmpty);
    expect(require<JSObject>('node:fs'), isNotNull);
    expect(() => require<JSObject>('no_such_module'), throwsA(isA<JSObject>()));
  });
}
```

## Common mistakes

* Calling `require` or reading `exports` in code that also runs on the VM or
  in a browser.
* Expecting `process.cwd()` to work in a browser build: it throws.
* Forgetting `process.exit(0)` at the end of an interactive node program.

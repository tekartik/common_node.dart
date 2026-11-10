# tekartik_stdio_node_test

Tests and demos of `tekartik_stdio_node` (readline prompts and the process
on Node.js). A test package, not a dependency.

## Running

From this folder, with node on the `PATH`:

```bash
dart test -p node,vm
```

The interactive demo (`bin/main.dart`, asks a question then exits) is
compiled with dart2js and run by node, stdin connected:

```bash
dart run tool/build_and_run_node.dart
```

`tool/build_and_run_raw_node.dart` does the same for `node/raw_node.dart`,
the raw `node:readline/promises` interop. Both write `build/` and
`deploy/main.js` (generated, do not commit).

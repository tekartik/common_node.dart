# tekartik_fs_node_test

Runs the fs_shim conformance suite (`tekartik_fs_test`, from
[fs_shim.dart](https://github.com/tekartik/fs_shim.dart)) against
`tekartik_fs_node` on Node.js: `fileSystemNode` and its sandbox, plus the
memory file system on node and on the Dart VM. A test package, not a
dependency.

## Running

From this folder, with node on the `PATH`:

```bash
dart test -p node,vm
```

* `test/node/fs_node_test.dart`: the whole suite (`defineTests`) on
  `fileSystemNode`, files under `.dart_tool/tekartik_fs_node/test/`.
* `test/node/fs_node_sandbox_test.dart`: the same suite in a sandbox.
* `test/node/fs_node_open_read_fd_test.dart`: `openRead` releases its file
  descriptors (linux only).
* `test/multiplatform/`: the memory file system and `fs_node_universal` on
  node and on the VM.

`dart_test.yaml` runs the files one at a time (`concurrency: 1`): the node
tests share their folders. The random access and link parts of the suite
are skipped or do nothing (`fileSystemNode` supports neither).

## Adding a node test context

`test/node/test_common_node.dart` shows the `FileSystemTestContext` of
node: copy it to run the suite on another node based file system.

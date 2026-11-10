# tekartik_platform_node

The Node.js implementation of
[tekartik_platform](https://github.com/tekartik/platform.dart): which OS a
Dart program compiled to JavaScript (dart2js) and run by node runs on, its
environment variables and the node version, plus a universal context picking
node or the Dart VM (`tekartik_platform_io`).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_platform_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: platform_node
```

```dart
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';

void main() {
  if (isRunningInNode) {
    // {node: {platform: linux}}
    print(platformContextNode.toMap());
    print('node $nodeVersion');
  }
  // node when compiled to JavaScript, the Dart VM otherwise.
  var env = platformUniversal.environment;
  print('${env.length} environment variables');
}
```

Run it on node with `dart test -p node` (in a test) or after a dart2js build
(`tekartik_build_node`).

## Platforms

* node (dart2js): `platformContextNode` (`node` and `platform` set, `io` and
  `browser` null), `nodeVersion`, `isRunningInNode` true.
* Dart VM: importing is safe, `platformContextNode` and `nodeVersion` throw
  an `UnimplementedError`; `platformContextUniversal` is the io context.
* Browser: `isRunningInNode` and `isRunningInNodeOrIo` are false; do not
  read `platformContextUniversal` there.

## Entry points

* `package:tekartik_platform_node/context_node.dart`: `platformContextNode`,
  `nodeVersion`, `isRunningInNode`, `isRunningInNodeOrIo`,
  `nodeFixRandomSecure()` (call it first in a `dart test -p node` main using
  `Random.secure()`).
* `package:tekartik_platform_node/context_universal.dart`:
  `platformContextUniversal`, `platform` and `platformUniversal`.
* `package:tekartik_platform_node/util/github_util.dart`: `runningOnGithub`.

## Common pitfalls

* `environment` builds a new map from `process.env` at each read: keep it in
  a local. Its keys keep their case, also on Windows (`Path`, not `PATH`),
  unlike `dart:io`.
* Never print the whole environment (tests, logs): it holds the secrets of
  the machine.
* Guard browser code with `isRunningInNodeOrIo` before
  `platformContextUniversal`.

Agent skill: [skills/tekartik-platform-node-setup](skills/tekartik-platform-node-setup/SKILL.md).

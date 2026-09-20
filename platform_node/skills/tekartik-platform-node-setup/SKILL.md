---
name: tekartik-platform-node-setup
description: >-
  Use when Dart code compiled for Node.js needs platform information through
  the tekartik_platform PlatformContext abstraction with
  tekartik_platform_node: platformContextNode (node OS flags isLinux /
  isMacOS / isWindows and environment variables), nodeVersion,
  isRunningInNode, isRunningInNodeOrIo, platformContextUniversal / platform
  / platformUniversal (node when running as JavaScript, platformContextIo on
  the VM), runningOnGithub, the context_node.dart / context_universal.dart
  / util/github_util.dart imports, and node vs VM vs browser detection.
---

# tekartik_platform_node: platform context on Node.js (tekartik_platform_node)

`tekartik_platform_node` implements `PlatformContext` / `Platform` from
`tekartik_platform` for Dart compiled to JavaScript and run by Node.js
(`require('os')` and `process.env`), and offers a universal getter that
falls back to `tekartik_platform_io` on the VM. Use it wherever node code
needs the OS name, environment variables or the node version.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_platform_node:
      git:
        url: https://github.com/tekartik/common_node.dart
        path: platform_node
    tekartik_platform:
      git:
        url: https://github.com/tekartik/platform.dart
        path: platform
  ```
  `tekartik_platform` is only needed explicitly to name the `PlatformContext`
  and `Platform` types (`package:tekartik_platform/context.dart`).
* Imports:
  * `package:tekartik_platform_node/context_node.dart`: `platformContextNode`
    (a `PlatformContext`), `nodeVersion` (a `pub_semver` `Version`),
    `isRunningInNode` and `isRunningInNodeOrIo`.
  * `package:tekartik_platform_node/context_universal.dart`:
    `platformContextUniversal`, and `platform` / `platformUniversal` (both
    the non-null `platformContextUniversal.platform!`).
  * `package:tekartik_platform_node/util/github_util.dart`:
    `runningOnGithub` (`GITHUB_ACTIONS == 'true'` in the universal
    environment).
* `PlatformContext` has `browser`, `io`, `node` and `platform` getters plus
  `toMap()`; on node only `node` and `platform` are non-null and `toMap()`
  is `{'node': {'platform': 'linux' | 'macos' | 'windows'}}`. `Platform`
  (also `Node`) exposes `isWindows`, `isMacOS`, `isLinux` and
  `environment`; `environment` builds a fresh `Map<String, String>` from
  `process.env` on every read, so cache it in a local.
* `nodeVersion` parses `process.version` (`v22.1.0` gives `22.1.0`) once;
  compare with `Version(major, minor, patch)` from `pub_semver`.
* Detection: `isRunningInNode` looks for `process.versions.node` in the JS
  global scope (false on the VM and in browsers); `isRunningInNodeOrIo` is
  `!kDartIsWeb || isRunningInNode`, the switch for "a `Platform` with
  environment variables exists". Off node `platformContextNode` and
  `nodeVersion` throw `UnimplementedError` (importing is safe).
* `platformContextUniversal` is `platformContextNode` whenever the code runs
  as JavaScript and `platformContextIo` otherwise: right for node builds
  and VM scripts, wrong in a browser. Code that also targets browsers picks
  `isRunningInNodeOrIo ? platformContextUniversal : platformContextBrowser`
  (`platformContextBrowser` from `tekartik_platform_browser`,
  `context_browser.dart`).
* `dart:io` `Platform` does not exist on node; the shim in
  `lib/src/interop/platform_interop.dart` backs `platformContextNode` and is
  not public API.
* Tests: `dart test -p vm,node`; tag node-only expectations
  `@TestOn('node')`, universal ones `@TestOn('vm || node')`.
  `tekartik_platform_test` (`platform_context_example.dart`,
  `run(PlatformContext)`) prints a context for manual checks.

## Examples

### Dump the node context

```dart
import 'dart:convert';

import 'package:tekartik_platform_node/context_node.dart';

void main() {
  print(const JsonEncoder.withIndent('  ').convert(platformContextNode.toMap()));
  print('node $nodeVersion');
  var env = platformContextNode.node!.environment;
  print('home: ${env['HOME'] ?? env['USERPROFILE']}');
}
```

### Environment lookups shared between node and the VM

```dart
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:tekartik_platform_node/util/github_util.dart';

String get configDir {
  var env = platform.environment;
  if (platform.isWindows) {
    return env['APPDATA'] ?? '.';
  }
  return env['XDG_CONFIG_HOME'] ?? '${env['HOME']}/.config';
}

void main() {
  print('on node: ${platformContextUniversal.node != null}');
  print('on github actions: $runningOnGithub');
  print(configDir);
}
```

### Detect node, VM or browser

```dart
import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';

/// Null in a browser, where there is no environment.
PlatformContext? get serverPlatformContext =>
    isRunningInNodeOrIo ? platformContextUniversal : null;

void main() {
  var context = serverPlatformContext;
  if (context == null) {
    print('browser');
  } else if (isRunningInNode) {
    print('node ${nodeVersion.major}: ${context.node!.environment.length} vars');
  } else {
    print('dart vm: ${context.io!.environment.length} vars');
  }
}
```

### Node-only test

```dart
@TestOn('node')
library;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

void main() {
  test('node context', () {
    expect(isRunningInNode, isTrue);
    expect(platformContextNode.node, isNotNull);
    expect(platformContextNode.io, isNull);
    expect(nodeVersion, greaterThan(Version(18, 0, 0)));
  });
}
```

## Common mistakes

* Using `platformContextUniversal` in a browser build: guard with
  `isRunningInNodeOrIo` first.
* Reading `platform.environment` in a loop: it rebuilds the map each time.
* Accessing `platformContextNode` or `nodeVersion` from VM code.

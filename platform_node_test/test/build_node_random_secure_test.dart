@TestOn('vm')
library;

import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_build_node/build_node.dart';
import 'package:test/test.dart';

/// The major version of the node found in the path, null if none.
int? _nodeMajorVersion() {
  var node = whichSync('node');
  if (node == null) {
    return null;
  }
  var result = Process.runSync(node, ['--version']);
  var match = RegExp(r'^v(\d+)').firstMatch('${result.stdout}'.trim());
  return match == null ? null : int.parse(match.group(1)!);
}

void main() {
  var nodeMajorVersion = _nodeMajorVersion();
  test(
    'build_node output, Random.secure',
    () async {
      var output = 'build/node/random_secure.dart.js';
      await nodePackageCompileJs(
        '.',
        input: 'node/random_secure.dart',
        output: output,
      );
      var result = await run('node $output', verbose: false);
      expect(result.outText, contains('Random.secure: ok'));
    },
    skip: nodeMajorVersion == null
        ? 'node not found'
        // No global crypto before node 19, Random.secure() cannot work.
        : nodeMajorVersion < 19
        ? 'No global crypto before node 19'
        : null,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

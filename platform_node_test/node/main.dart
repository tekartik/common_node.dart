import 'dart:convert';

import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:tekartik_platform_test/platform_context_example.dart' as common;
import 'platform_io.dart' if (dart.library.js_interop) 'platform_node.dart';

void main() {
  run(platformContextUniversal);
}

void run(PlatformContext context) {
  print(const JsonEncoder.withIndent('  ').convert(context.toMap()));

  common.print = print;
  common.run(context);
  if (context.node != null) {
    print('nodeVersion: $nodeVersion');
  }
  dumpPlatformInfo();
}

/*
 linux

 {
  "io": {
    "platform": "linux"
  }
}
 */

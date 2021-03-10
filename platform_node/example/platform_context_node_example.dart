import 'dart:convert';
import 'package:tekartik_platform/context.dart';

import 'package:tekartik_platform_node/context_node.dart';
import 'package:tekartik_platform_test/platform_context_example.dart' as common;

void main() {
  run(platformContextNode);
}

void run(PlatformContext context) {
  print(const JsonEncoder.withIndent('  ').convert(context.toMap()));

  common.print = print;
  common.run(context);
}

/*
 linux

 {
  "io": {
    "platform": "linux"
  }
}
 */

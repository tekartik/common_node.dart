import 'package:tekartik_common_utils/version_utils.dart';
import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_node/src/context_node.dart' as node;
import 'package:tekartik_platform_node/src/interop/process_interop.dart'
    as node;

PlatformContext get platformContextNode => node.platformContextNode;

Version? _nodeVersion;
Version get nodeVersion => _nodeVersion ??= () {
  var versionText = node.process.version;
  if (versionText.startsWith('v')) {
    versionText = versionText.substring(1);
  }
  return parseVersion(versionText);
}();

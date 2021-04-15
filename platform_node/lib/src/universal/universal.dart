import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform/context.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform_node/context_node.dart';

/// Universal platform context
PlatformContext get platformContextUniversal =>
    isRunningAsJavascript ? platformContextNode : platformContextIo;

/// Get the platform information
Platform get platform => platformContextUniversal.platform!;

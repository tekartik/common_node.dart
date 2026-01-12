import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_platform/context.dart';

/// Global platform context node instance.
PlatformContext get platformContextNode =>
    throw UnimplementedError('platformContextIo Node only');

/// Node version.
Version get nodeVersion => throw UnimplementedError('nodeVersion node only');

/// By default not running in node js mode
bool get isRunningInNode => false;

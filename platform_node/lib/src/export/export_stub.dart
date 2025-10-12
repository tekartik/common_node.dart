import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_platform/context.dart';

PlatformContext get platformContextNode =>
    throw UnimplementedError('platformContextIo Node only');
Version get nodeVersion => throw UnimplementedError('nodeVersion node only');

/// By default not running in node js mode
bool get isRunningInNode => false;

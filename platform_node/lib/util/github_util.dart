import 'package:tekartik_platform_node/context_universal.dart';

/// True if running on GitHub.
bool get runningOnGithub =>
    platformUniversal.environment['GITHUB_ACTIONS'] == 'true';

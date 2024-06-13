import 'package:tekartik_platform_node/context_universal.dart';

bool get runningOnGithub =>
    platformUniversal.environment['GITHUB_ACTIONS'] == 'true';

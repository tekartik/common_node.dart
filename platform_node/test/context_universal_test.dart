import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

bool get runningOnTravis => platform.environment['TRAVIS'] == 'true';
bool get runningOnGithub => platform.environment['GITHUB_ACTIONS'] == 'true';

void main() {
  group('universal', () {
    test('info', () {
      print(platform.environment);
      expect(platformContextUniversal.platform!.environment, isNotEmpty);
      if (isRunningAsJavascript) {
        expect(platformContextUniversal.node, isNotNull);
        expect(platformContextUniversal.io, isNull);
      } else {
        expect(platformContextUniversal.node, isNull);
        expect(platformContextUniversal.io, isNotNull);
      }
    });
    test('ci', () {
      print('running on travis: $runningOnTravis');
      print('running on github: $runningOnGithub');
    });
  });
}

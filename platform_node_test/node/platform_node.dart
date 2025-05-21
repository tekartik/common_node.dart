import 'package:tekartik_platform_node/src/interop/platform_interop.dart'
    as node;

void dumpPlatformInfo() {
  print('node.Platform.pathSeparator: ${node.Platform.pathSeparator}');
  print(
    'node.Platform.resolvedExecutable: ${node.Platform.resolvedExecutable}',
  );
  print('node.Platform.executable: ${node.Platform.executable}');
  print(
    'node.Platform.executableArguments: ${node.Platform.executableArguments}',
  );
  print('node.Platform.arguments: ${node.Platform.arguments}');

  print('node.Platform.localHostname: ${node.Platform.localHostname}');
  print('node.Platform.operatingSystem: ${node.Platform.operatingSystem}');
  print(
    'node.Platform.operatingSystemVersion: ${node.Platform.operatingSystemVersion}',
  );
  print(
    'node.Platform.numberOfProcessors: ${node.Platform.numberOfProcessors}',
  );
}

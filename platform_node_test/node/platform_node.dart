import 'package:tekartik_platform_node/src/interop/platform_interop.dart'
    as node;

void _log(Object? object) {
  // ignore: avoid_print
  print(object);
}

void dumpPlatformInfo() {
  _log('node.Platform.pathSeparator: ${node.Platform.pathSeparator}');
  _log('node.Platform.resolvedExecutable: ${node.Platform.resolvedExecutable}');
  _log('node.Platform.executable: ${node.Platform.executable}');
  _log(
    'node.Platform.executableArguments: ${node.Platform.executableArguments}',
  );
  _log('node.Platform.arguments: ${node.Platform.arguments}');

  _log('node.Platform.localHostname: ${node.Platform.localHostname}');
  _log('node.Platform.operatingSystem: ${node.Platform.operatingSystem}');
  _log(
    'node.Platform.operatingSystemVersion: ${node.Platform.operatingSystemVersion}',
  );
  _log('node.Platform.numberOfProcessors: ${node.Platform.numberOfProcessors}');
}

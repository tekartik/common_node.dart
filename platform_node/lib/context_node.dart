/// The node (dart2js) platform context: [platformContextNode],
/// [nodeVersion], [isRunningInNode], [isRunningInNodeOrIo] and
/// [nodeFixRandomSecure]. Safe to import on the Dart VM and in browsers, where
/// [platformContextNode] and [nodeVersion] throw.
library;

export 'src/export/export.dart'
    show platformContextNode, nodeVersion, isRunningInNode, isRunningInNodeOrIo;
export 'src/node_fix_random_secure.dart' show nodeFixRandomSecure;

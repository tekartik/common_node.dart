import 'package:node_io/node_io.dart' as node;
import 'package:tekartik_platform/context.dart';
// ignore: implementation_imports
import 'package:tekartik_platform/src/platform_mixin.dart';

class NodeImpl with PlatformMixin implements Node {
  @override
  bool get isLinux => node.Platform.isLinux;

  @override
  bool get isMac => isMacOS;

  @override
  bool get isWindows => node.Platform.isWindows;

  String get _platformText {
    String platform;
    if (isLinux) {
      platform = 'linux';
    } else if (isMac) {
      platform = 'mac';
    } else if (isWindows) {
      platform = 'windows';
    }
    return platform;
  }

  @override
  String toString() => toMap().toString();

  @override
  Map<String, String> get environment => node.Platform.environment;

  @override
  bool get isMacOS => node.Platform.isMacOS;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['platform'] = _platformText;
    map = getPlatformInfoMap(map);
    return map;
  }
}

class PlatformContextNode implements PlatformContext {
  @override
  Browser get browser => null;

  @override
  Io get io => null;

  NodeImpl _node;

  @override
  NodeImpl get node => _node ??= NodeImpl();

  @override
  String toString() => '[node] $node';

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'node': node.toMap()};
    return map;
  }

  @override
  Platform get platform => node;
}

PlatformContextNode _platformContextNode;

PlatformContextNode get platformContextNode =>
    _platformContextNode ??= PlatformContextNode();

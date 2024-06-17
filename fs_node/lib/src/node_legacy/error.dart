import 'package:fs_shim/fs.dart' as fs_shim;

class NodeOSError implements fs_shim.OSError {
  @override
  final int errorCode;

  @override
  final String message;

  const NodeOSError(
      {this.errorCode = fs_shim.OSError.noErrorCode, required this.message});
}

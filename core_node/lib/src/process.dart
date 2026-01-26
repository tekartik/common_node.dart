/// Abstraction for process-related operations.
abstract class Process {
  /// Exit the process with the given exit code.
  void exit(int code);

  /// Current directory
  String cwd();
}

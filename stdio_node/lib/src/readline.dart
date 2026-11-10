export 'universal/universal.dart' show readline;

/// Readline module.
class ReadlineModule {}

/// Readline interface.
abstract class Readline {
  /// Prompts a query to the user and returns the user's input.
  ///
  /// The prompt is written as is (add the trailing space yourself), the
  /// answer has no new line.
  Future<String> question(String prompt);

  /// Close the interface so that the program can exit.
  ///
  /// On node a later [question] creates a new interface; on the Dart VM
  /// stdin cannot be read again. Calling it twice is fine.
  void close();
}

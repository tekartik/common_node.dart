export 'universal/universal.dart' show readline;

/// Readline module.
class ReadlineModule {}

/// Readline interface.
abstract class Readline {
  /// Prompts a query to the user and returns the user's input.
  Future<String> question(String prompt);

  /// Close the interface.
  void close();
}

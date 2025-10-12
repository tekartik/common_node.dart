export 'universal/universal.dart' show readline;

class ReadlineModule {}

abstract class Readline {
  // Implementation for reading a line from stdin with a prompt
  Future<String> question(String prompt);
  void close();
}

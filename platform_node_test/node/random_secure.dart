import 'dart:math';

/// Built by build_node then run by `test/build_node_random_secure_test.dart`:
/// no `nodeFixRandomSecure()` here, the build_node preamble alone must make
/// `Random.secure()` work.
void main() {
  // ignore: avoid_print
  print('Random.secure: ok ${Random.secure().nextInt(10)}');
}

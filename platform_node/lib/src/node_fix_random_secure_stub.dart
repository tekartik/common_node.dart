/// Makes `Random.secure()` work in a dart2js node program, nothing to do on
/// the VM: returns false.
bool nodeFixRandomSecure() => false;

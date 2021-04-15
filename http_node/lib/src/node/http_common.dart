export 'package:tekartik_http/http.dart';

class NodeHttpStatus {
  static const int serviceUnavailable = 503;
  static const int movedPermanently = 301;
  static const int found = 302;
  static const int seeOther = 303;
  static const int temporaryRedirect = 307;
  static const int movedTemporarily = 302;
}

/// Imported from dart:io
class NodeHttpHeaders {
  static const locationHeader = 'location';
}

const nodeContentLengthHeader = 'content-length';

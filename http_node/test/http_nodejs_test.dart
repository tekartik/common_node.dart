@TestOn('node')
library;

import 'package:tekartik_http_node/src/nodejs/http_interop.dart';
import 'package:tekartik_http_node/src/nodejs/http_node.dart';
import 'package:tekartik_http_node/src/nodejs/utils_js.dart';
import 'package:test/test.dart';

void main() {
  test('JsHttpNode', () {
    var jsHttpNodeImpl = jsHttpNode;

    print(jsHttpNodeImpl);
    print(getOwnPropertyNames(jsHttpNodeImpl));
    print(getKeys(jsHttpNodeImpl));
  });
  test('HttpNodeJs()', () async {
    var serverJs = httpNodeJs.createServer((_, __) {
      print('server created');
    });
    await serverJs.listen();
    print(serverJs.address());
    print('server listening');
  });
}

# The node fetch client

`httpClientFactoryNode`, `httpClientFactoryNodeFetch` and, on node,
`httpClientFactoryUniversal` return a `package:http` `BrowserClient`
(http >= 1.4.0), which calls node's global `fetch` (undici).

What differs from the `dart:io` client (checked by
`http_client_conformance_tests` in `http_node_test`):

* Request bodies are sent in one piece (no streaming); response bodies are
  streamed.
* Redirects are always followed; with `followRedirects = false` a redirect
  throws a `ClientException` instead of returning the 3xx response;
  `maxRedirects` is ignored.
* `cookie` request headers are not sent and `set-cookie` response headers
  are not received (fetch forbids them).
* No folded response headers, no multipart requests, no use from another
  isolate.
* The reason phrase comes from the fetch `statusText`, which can be empty.

Design node calls around JSON bodies and explicit headers.

## Test setup

```yaml
 tekartik_http_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: http_node
      ref: dart3a
```
    Need dart > 2
        
## Test

    pub run test -p vm,node
    
    pbr test -- p node
    
    nodetest
    
    # Test only real http
    pbr test -- -p node test/http_node_test.dart


## Running test server


    pbr build -o example:build ; node build/test_server.dart.js

## Setup

```yaml
  tekartik_platform_node:
    git:
      url: git://github.com/tekartik/common_node.dart
      path: platform_node
      ref: null_safety
    version: '>=0.2.1'

```
Use dart2

    pbr build example --output=example:build
    node build/platform_context_node_example.dart.js
    
or

    noderun example/platform_context_node_example.dart 

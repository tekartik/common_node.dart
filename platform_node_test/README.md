## Setup

```yaml
  tekartik_platform_node:
    git:
      url: https://github.com/tekartik/platform.dart
      path: platform_node
      ref: dart3a
    version: '>=0.2.1'

```
Use dart2

    pbr build example --output=example:build
    node build/platform_context_node_example.dart.js
    
or

    noderun example/platform_context_node_example.dart 

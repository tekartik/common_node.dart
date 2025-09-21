## Setup

```yaml
  tekartik_fs_node:
    git:
      url: https://github.com/tekartik/common_node.dart
      path: fs_node
    version: '>=0.4.0'

```

## Test setup

    User dart2
        
## Test

    pbr test -- -p node
    
    pub run test -p vm,node
    
    pbr test -- -p node
 

## Testing node_io

    pbr test -- -p node test/directory_test.dart test/file_stat_test.dart test/file_test.dart 

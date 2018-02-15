## Overview

Test drive in Amazon land is called "Quick Start".

[Entry point to docs is here](https://aws-quickstart.github.io/)

## Dependencies

```
brew install packer
```

## Build Neo4j Enterprise AMI

This will take whatever is the latest stable.

```
packer build neo4j-enterprise.json
```

If you're upgrading, note you should change `ami_name` in that JSON file, so the AMI is clear on what it is.


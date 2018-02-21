## Overview

Test drive in Amazon land is called "Quick Start".

[Entry point to docs is here](https://aws-quickstart.github.io/)

## Dependencies

* `brew install packer`
* Install AWS CLI and authenticate

## Build Neo4j Enterprise AMI

You should specify edition (community/enterprise) and version.

Optionally, you can omit the AWS key variables and set them in your environment.

```
packer build \
    -var "neo4j_edition=enterprise" \
    -var "neo4j_version=3.3.3" \
    neo4j-enterprise.json
```

Check the variables at the top of the JSON file for other options you can override/set.

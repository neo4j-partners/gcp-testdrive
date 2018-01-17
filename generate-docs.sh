#!/bin/bash
# Run me to generate the test drive content from ASCIIdoc -> HTML suitable for staging.

for file in content/*.adoc ; do
   html="${file%.*}".html
   ./neo4j-guides/run.sh "$file" $html ;
done

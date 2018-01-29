#!/bin/bash

while true; do
  if curl -s -I http://35.227.153.92:7474 | grep "200 OK"; then
    echo "Neo4j is up"
    break
  fi
 
  echo "Waiting for neo4j to come up..."
  sleep 5
done



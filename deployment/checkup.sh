#!/bin/bash

IP=35.199.148.44

while true; do
  if curl -s -I http://$IP:7474 | grep "200 OK"; then
    echo "Neo4j is up"
    break
  fi
 
  echo "Waiting for neo4j to come up..."
  sleep 5
done



#!/bin/bash

s3cmd put -P --recursive content/* s3://guides.neo4j.com/gcloud-testdrive/

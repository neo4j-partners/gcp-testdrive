#!/bin/bash
PROJECT=test-drive-public
TEMPLATE=gcloud/deployment/install.jinja
DEPLOYMENT_NAME=testdeploy-$(head -c 3 /dev/urandom | md5 | head -c 4)
export deployment=$DEPLOYMENT_NAME

echo "Creating deployment $DEPLOYMENT_NAME"
gcloud deployment-manager deployments create $DEPLOYMENT_NAME \
   --template $TEMPLATE \
   --project $PROJECT


#!/bin/bash

# From https://stackoverflow.com/a/55658863
# Additional info on https://github.com/k3s-io/k3s/issues/1427

PATH="/usr/local/bin:/usr/bin:/bin"

ACCOUNT=980925581578
REGION=us-east-1
SECRET_NAME=${REGION}-ecr-registry
EMAIL=no@email.com

#
#

TOKEN=`aws ecr --region=$REGION get-authorization-token --output text \
    --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`

#
#  Create or replace registry secret
#

kubectl create namespace $NAMESPACE
kubectl delete secret --namespace=${NAMESPACE} --ignore-not-found $SECRET_NAME
kubectl create secret docker-registry $SECRET_NAME \
    --namespace=${NAMESPACE} \
    --docker-server=https://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com \
    --docker-username=AWS \
    --docker-password="${TOKEN}" \
    --docker-email="${EMAIL}"

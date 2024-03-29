#!/bin/bash
SERVICE_PRINCIPAL_ID="$1"
SERVICE_PRINCIPAL_PASSWORD="$2"
TENANT_ID="$3"
SUBSCRIPTION_ID="$4"
IMAGE_NAME="$5"
IMAGE_TAG="$6"
REGISTRY_NAME="$7"
DOCKERFILE_PATH="$8"
DOCKERFILE_CONTEXT="$9"

az login --service-principal -u $SERVICE_PRINCIPAL_ID -p $SERVICE_PRINCIPAL_PASSWORD --tenant $TENANT_ID

az account set --subscription $SUBSCRIPTION_ID

az acr build -t $IMAGE_NAME:$IMAGE_TAG -r $REGISTRY_NAME -f $DOCKERFILE_PATH $DOCKERFILE_CONTEXT

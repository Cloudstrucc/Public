#!/bin/bash
RESOURCE_GROUP=ariesCanadaRG
az group create --name $RESOURCE_GROUP --location canadacentral
az deployment group create --resource-group $RESOURCE_GROUP --template-file infra/sandbox-arm/azuredeploy.json --parameters infra/sandbox-arm/azuredeploy.parameters.json
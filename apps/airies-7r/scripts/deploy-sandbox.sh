#!/bin/bash

# Deploy Aries Canada Sandbox Infrastructure
set -e

RESOURCE_GROUP=${RESOURCE_GROUP:-ariesCanadaV2RG}
LOCATION=${LOCATION:-canadacentral}
DEPLOYMENT_NAME="aries-v2-sandbox-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Deploying Aries Canada V2 Sandbox Infrastructure..."
echo "📍 Resource Group: $RESOURCE_GROUP"
echo "🌍 Location: $LOCATION"
echo "📦 Deployment: $DEPLOYMENT_NAME"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Create resource group
echo "📁 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy ARM template
echo "🏗️  Deploying ARM template..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --template-file infra/sandbox-arm/azuredeploy.json \
  --parameters infra/sandbox-arm/azuredeploy.parameters.json

# Get deployment outputs
echo "📋 Getting deployment outputs..."
HOSTNAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query 'properties.outputs.hostname.value' \
  --output tsv)

SSH_COMMAND=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query 'properties.outputs.sshCommand.value' \
  --output tsv)

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Hostname: $HOSTNAME"
echo "🔗 SSH Command: $SSH_COMMAND"
echo ""
echo "Next steps:"
echo "1. SSH into the VM: $SSH_COMMAND"
echo "2. Clone this repository"
echo "3. Run the setup script"
echo "4. Start the Docker containers"

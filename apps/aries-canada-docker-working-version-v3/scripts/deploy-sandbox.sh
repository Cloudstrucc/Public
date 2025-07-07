#!/bin/bash

# Deploy Aries Canada Sandbox Infrastructure (Complete)
set -e

RESOURCE_GROUP=${RESOURCE_GROUP:-ariesCanadaRG}
LOCATION=${LOCATION:-canadacentral}
DEPLOYMENT_NAME="aries-sandbox-$(date +%Y%m%d-%H%M%S)"
SUBSCRIPTION_ID=${SUBSCRIPTION_ID:-}

echo "🚀 Deploying Aries Canada Sandbox Infrastructure..."
echo "📍 Resource Group: $RESOURCE_GROUP"
echo "🌍 Location: $LOCATION"
echo "📦 Deployment: $DEPLOYMENT_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Determine script location and set paths accordingly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ARM template paths (relative to project root)
TEMPLATE_PATH="$PROJECT_ROOT/infra/sandbox-arm/azuredeploy.json"
PARAMETERS_PATH="$PROJECT_ROOT/infra/sandbox-arm/azuredeploy.parameters.json"

echo -e "${BLUE}🔍 Checking file paths...${NC}"
echo "   Script location: $SCRIPT_DIR"
echo "   Project root: $PROJECT_ROOT"
echo "   Template: $TEMPLATE_PATH"
echo "   Parameters: $PARAMETERS_PATH"

# Check if ARM template files exist
if [ ! -f "$TEMPLATE_PATH" ]; then
    echo -e "${RED}❌ ARM template not found: $TEMPLATE_PATH${NC}"
    echo -e "${YELLOW}💡 Make sure you're running this from the correct directory${NC}"
    echo -e "${YELLOW}💡 Expected structure:${NC}"
    echo "   project-root/"
    echo "   ├── scripts/deploy-sandbox.sh"
    echo "   └── infra/sandbox-arm/azuredeploy.json"
    exit 1
fi

if [ ! -f "$PARAMETERS_PATH" ]; then
    echo -e "${RED}❌ Parameters file not found: $PARAMETERS_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ ARM template files found${NC}"

# Check prerequisites
echo -e "${BLUE}🔍 Checking Azure CLI prerequisites...${NC}"

# Check if Azure CLI is installed
if ! command -v az > /dev/null 2>&1; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    echo -e "${YELLOW}💡 Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

# Get current subscription
CURRENT_SUB=$(az account show --query id -o tsv)
echo -e "${GREEN}✅ Logged in to Azure subscription: $CURRENT_SUB${NC}"

# Set subscription if provided
if [ -n "$SUBSCRIPTION_ID" ] && [ "$SUBSCRIPTION_ID" != "$CURRENT_SUB" ]; then
    echo -e "${BLUE}🔄 Switching to subscription: $SUBSCRIPTION_ID${NC}"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Verify location is valid
echo -e "${BLUE}🌍 Verifying location: $LOCATION${NC}"
if ! az account list-locations --query "[?name=='$LOCATION']" -o tsv | grep -q "$LOCATION"; then
    echo -e "${RED}❌ Invalid location: $LOCATION${NC}"
    echo -e "${YELLOW}💡 Available locations:${NC}"
    az account list-locations --query "[].name" -o table
    exit 1
fi

# Create resource group
echo -e "${BLUE}📁 Creating resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Resource group created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create resource group${NC}"
    exit 1
fi

# Validate ARM template
echo -e "${BLUE}✅ Validating ARM template...${NC}"
VALIDATION_RESULT=$(az deployment group validate \
  --resource-group $RESOURCE_GROUP \
  --template-file "$TEMPLATE_PATH" \
  --parameters "$PARAMETERS_PATH" 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ARM template validation passed${NC}"
else
    echo -e "${RED}❌ ARM template validation failed:${NC}"
    echo "$VALIDATION_RESULT"
    exit 1
fi

# Deploy ARM template
echo -e "${BLUE}🏗️  Deploying ARM template...${NC}"
echo -e "${YELLOW}⏳ This may take 10-15 minutes...${NC}"

DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --template-file "$TEMPLATE_PATH" \
  --parameters "$PARAMETERS_PATH" \
  --query 'properties.outputs' \
  --output json)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ARM template deployment completed successfully${NC}"
else
    echo -e "${RED}❌ ARM template deployment failed${NC}"
    echo "Check deployment logs:"
    az deployment group list --resource-group $RESOURCE_GROUP --query "[?name=='$DEPLOYMENT_NAME']"
    exit 1
fi

# Extract deployment outputs
echo -e "${BLUE}📋 Getting deployment outputs...${NC}"
HOSTNAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.hostname.value // "unknown"')
SSH_COMMAND=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.sshCommand.value // "unknown"')
PUBLIC_IP=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.publicIPAddress.value // "unknown"')
KEY_VAULT_NAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.keyVaultName.value // "unknown"')
STORAGE_ACCOUNT=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.storageAccountName.value // "unknown"')

# Display deployment results
echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo "   🏷️  Deployment Name: $DEPLOYMENT_NAME"
echo "   📁 Resource Group: $RESOURCE_GROUP"
echo "   🌍 Location: $LOCATION"
echo "   🌐 Hostname: $HOSTNAME"
echo "   🔗 Public IP: $PUBLIC_IP"
echo "   🔐 Key Vault: $KEY_VAULT_NAME"
echo "   💾 Storage Account: $STORAGE_ACCOUNT"
echo ""
echo -e "${BLUE}🔗 Connection Information:${NC}"
echo "   SSH Command: $SSH_COMMAND"
echo ""
echo -e "${BLUE}🔧 Next Steps:${NC}"
echo "   1. SSH into the VM: $SSH_COMMAND"
echo "   2. Clone this repository on the VM"
echo "   3. Run the Aries stack: ./scripts/start-aries-stack.sh"
echo "   4. Configure DNS (optional): Point your domain to $PUBLIC_IP"
echo "   5. Set up TLS certificates: ./scripts/setup-tls.sh"
echo "   6. Harden security: ./scripts/harden-nsg.sh"
echo ""
echo -e "${YELLOW}⚠️  Security Reminders:${NC}"
echo "   🔒 Change default passwords in VM"
echo "   🔑 Store secrets in Key Vault: $KEY_VAULT_NAME"
echo "   🛡️  Configure NSG rules for your IP only"
echo "   📊 Enable monitoring and alerting"
echo ""

# Save deployment info to file (in scripts directory)
DEPLOYMENT_INFO_FILE="$SCRIPT_DIR/deployment-info-$(date +%Y%m%d-%H%M%S).json"
echo "$DEPLOYMENT_OUTPUT" > "$DEPLOYMENT_INFO_FILE"
echo -e "${GREEN}💾 Deployment info saved to: $DEPLOYMENT_INFO_FILE${NC}"

echo -e "${GREEN}🎉 Sandbox deployment complete!${NC}"

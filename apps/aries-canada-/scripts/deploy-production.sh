#!/bin/bash

# Deploy Aries Canada Production Infrastructure
set -e

RESOURCE_GROUP=${RESOURCE_GROUP:-ariesCanadaProdRG}
LOCATION=${LOCATION:-canadacentral}
DEPLOYMENT_NAME="aries-prod-$(date +%Y%m%d-%H%M%S)"
SUBSCRIPTION_ID=${SUBSCRIPTION_ID:-}

echo "🚀 Deploying Aries Canada Production Infrastructure..."
echo "📍 Resource Group: $RESOURCE_GROUP"
echo "🌍 Location: $LOCATION"
echo "📦 Deployment: $DEPLOYMENT_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Production deployment confirmation
echo -e "${RED}⚠️  PRODUCTION DEPLOYMENT WARNING${NC}"
echo -e "${YELLOW}This will deploy production infrastructure with real costs.${NC}"
echo -e "${YELLOW}Ensure you have reviewed all configuration settings.${NC}"
echo ""
read -p "Continue with production deployment? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    echo -e "${BLUE}Deployment cancelled.${NC}"
    exit 0
fi

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

# Verify SSH key in parameters
if grep -q "YOUR_SSH_PUBLIC_KEY_HERE" infra/prod-arm/azuredeploy.parameters.json; then
    echo -e "${RED}❌ SSH public key not configured in production parameters${NC}"
    echo -e "${YELLOW}💡 Update infra/prod-arm/azuredeploy.parameters.json with your SSH public key${NC}"
    exit 1
fi

# Create resource group
echo -e "${BLUE}📁 Creating production resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Validate ARM template
echo -e "${BLUE}✅ Validating production ARM template...${NC}"
az deployment group validate \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/prod-arm/azuredeploy.json \
  --parameters infra/prod-arm/azuredeploy.parameters.json

# Deploy ARM template
echo -e "${BLUE}🏗️  Deploying production ARM template...${NC}"
echo -e "${YELLOW}⏳ This may take 15-20 minutes...${NC}"

DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --template-file infra/prod-arm/azuredeploy.json \
  --parameters infra/prod-arm/azuredeploy.parameters.json \
  --query 'properties.outputs' \
  --output json)

# Extract and display results
HOSTNAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.hostname.value')
SSH_COMMAND=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.sshCommand.value')
PUBLIC_IP=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.publicIPAddress.value')
KEY_VAULT_NAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.keyVaultName.value')

echo ""
echo -e "${GREEN}✅ Production deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Production Deployment Summary:${NC}"
echo "   🌐 Hostname: $HOSTNAME"
echo "   🔗 Public IP: $PUBLIC_IP"
echo "   🔐 Key Vault: $KEY_VAULT_NAME"
echo "   🔗 SSH Command: $SSH_COMMAND"
echo ""
echo -e "${BLUE}🔧 Production Next Steps:${NC}"
echo "   1. SSH into production VM"
echo "   2. Configure domain DNS to point to $PUBLIC_IP"
echo "   3. Set up TLS certificates for production domain"
echo "   4. Configure production secrets in Key Vault"
echo "   5. Set up monitoring and alerting"
echo "   6. Configure backup strategies"
echo "   7. Test disaster recovery procedures"
echo ""
echo -e "${RED}⚠️  Production Security Checklist:${NC}"
echo "   🔒 Change all default passwords"
echo "   🔑 Store all secrets in Key Vault"
echo "   🛡️  Configure NSG for minimal access"
echo "   📊 Enable Azure Security Center"
echo "   🔍 Set up log aggregation"
echo "   📈 Configure monitoring alerts"
echo ""

echo -e "${GREEN}🎉 Production deployment complete!${NC}"

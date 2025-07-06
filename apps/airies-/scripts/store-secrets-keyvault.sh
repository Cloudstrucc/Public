#!/bin/bash

# Store secrets in Azure Key Vault
set -e

VAULT_NAME=${VAULT_NAME:-aries-v2-kv-$(date +%s)}
RESOURCE_GROUP=${RESOURCE_GROUP:-ariesCanadaV2RG}
LOCATION=${LOCATION:-canadacentral}

echo "🔐 Setting up Azure Key Vault V2..."
echo "🏷️  Vault Name: $VAULT_NAME"
echo "📁 Resource Group: $RESOURCE_GROUP"

# Create Key Vault
echo "🏗️  Creating Key Vault..."
az keyvault create \
  --name "$VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku standard

# Generate secure keys
WALLET_KEY=$(openssl rand -base64 32)
MEDIATOR_KEY=$(openssl rand -base64 32)
API_KEY=$(openssl rand -base64 16)

# Store secrets
echo "💾 Storing secrets..."
az keyvault secret set --vault-name "$VAULT_NAME" --name "acapy-wallet-key" --value "$WALLET_KEY"
az keyvault secret set --vault-name "$VAULT_NAME" --name "mediator-wallet-key" --value "$MEDIATOR_KEY"
az keyvault secret set --vault-name "$VAULT_NAME" --name "admin-api-key" --value "$API_KEY"

echo "✅ Secrets stored successfully!"
echo "🔗 Key Vault URL: https://${VAULT_NAME}.vault.azure.net/"
echo ""
echo "📋 Stored secrets:"
echo "   - acapy-wallet-key"
echo "   - mediator-wallet-key"
echo "   - admin-api-key"
echo ""
echo "🔧 To use secrets in deployment:"
echo "   az keyvault secret show --vault-name $VAULT_NAME --name acapy-wallet-key --query value -o tsv"

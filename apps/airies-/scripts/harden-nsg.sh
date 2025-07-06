#!/bin/bash

# Harden Network Security Group rules
set -e

NSG_NAME=${NSG_NAME:-ariesV2NSG}
RESOURCE_GROUP=${RESOURCE_GROUP:-ariesCanadaV2RG}
TRUSTED_IP=${TRUSTED_IP:-0.0.0.0/0}  # CHANGE THIS TO YOUR IP!

echo "🛡️  Hardening Network Security Group V2..."
echo "🏷️  NSG Name: $NSG_NAME"
echo "📁 Resource Group: $RESOURCE_GROUP"
echo "🌐 Trusted IP: $TRUSTED_IP"

if [ "$TRUSTED_IP" = "0.0.0.0/0" ]; then
    echo "⚠️  WARNING: Using 0.0.0.0/0 allows access from anywhere!"
    echo "💡 Set TRUSTED_IP environment variable to your actual IP:"
    echo "   export TRUSTED_IP=\$(curl -s ifconfig.me)/32"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Remove existing rules (except defaults)
echo "🧹 Cleaning existing rules..."
az network nsg rule list --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" \
  --query "[?!starts_with(name, 'Default')].name" --output tsv | while read rule; do
    echo "  Deleting rule: $rule"
    az network nsg rule delete --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" --name "$rule"
done

# Add hardened rules
echo "🔒 Adding hardened rules..."

# SSH access (restricted to trusted IP)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowSSH" \
  --priority 100 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "$TRUSTED_IP" \
  --destination-port-ranges 22 \
  --description "SSH access from trusted IP"

# HTTP/HTTPS (public)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowHTTPHTTPS" \
  --priority 110 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 80 443 \
  --description "HTTP/HTTPS public access"

# ACA-Py agents V2 (public for DIDComm)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowACApy" \
  --priority 120 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 4000 4002 \
  --description "ACA-Py V2 DIDComm endpoints"

# Admin APIs V2 (restricted to trusted IP)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowAdmin" \
  --priority 130 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "$TRUSTED_IP" \
  --destination-port-ranges 4001 4003 \
  --description "ACA-Py V2 admin APIs from trusted IP"

# Von-network V2 ledger (public read access)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowVonNetwork" \
  --priority 140 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 8000-8708 \
  --description "Von-network V2 ledger access"

echo "✅ Network security group hardened!"
echo "🔐 Rules applied:"
echo "   - SSH: ${TRUSTED_IP} → port 22"
echo "   - HTTP/HTTPS: * → ports 80,443"
echo "   - ACA-Py DIDComm: * → ports 3000,3002"
echo "   - ACA-Py Admin: ${TRUSTED_IP} → ports 3001,3003"
echo "   - Von-network: * → ports 9000-9708"

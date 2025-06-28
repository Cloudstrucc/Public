#!/bin/bash
NSG_NAME="ariesNSG"
RESOURCE_GROUP="ariesCanadaRG"

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name AllowSSH --priority 100 --access Allow --protocol Tcp --direction Inbound \
  --source-address-prefixes 1.2.3.4/32 --destination-port-ranges 22

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name AllowHTTPHTTPS --priority 110 --access Allow --protocol Tcp --direction Inbound \
  --source-address-prefixes 1.2.3.4/32 --destination-port-ranges 80 443 3001 3003

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name DenyAllInbound --priority 200 --access Deny --protocol "*" --direction Inbound \
  --source-address-prefixes "*" --destination-port-ranges "*"

echo "NSG hardened: only trusted IPs allowed."

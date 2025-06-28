#!/bin/bash
VAULT_NAME="ariesKeyVault"

az keyvault create --name $VAULT_NAME --resource-group ariesCanadaRG --location canadacentral
az keyvault secret set --vault-name $VAULT_NAME --name acapy-wallet-key --value "replace-with-your-wallet-key"
az keyvault secret set --vault-name $VAULT_NAME --name bridge-client-secret --value "replace-with-your-client-secret"
echo "Secrets stored in Azure Key Vault: $VAULT_NAME"

# Get your current user's object ID
USER_ID=$(az ad signed-in-user show --query id --output tsv)

# Assign Key Vault Secrets Officer role
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee $USER_ID \
  --scope "/subscriptions/165df23b-fd23-4409-aa20-882904b24049/resourceGroups/ariesCanadaRG/providers/Microsoft.KeyVault/vaults/ariesdev0701"
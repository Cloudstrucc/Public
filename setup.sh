curl -X POST http://52.228.36.102:3003/wallet/did/create \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \ 
  -d '{
    "method": "sov",
    "options": {
      "key_type": "ed25519"
    }
  }'

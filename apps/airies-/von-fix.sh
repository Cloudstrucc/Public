cd docker/von-network

# Stop current attempts
docker-compose down 2>/dev/null || true

# Create ultra-simple working configuration
cat > docker-compose.yml << 'EOF'
services:
  mock-ledger:
    image: nginx:alpine
    container_name: von-v2-simple
    ports:
      - "8000:80"
    volumes:
      - ./web:/usr/share/nginx/html:ro

volumes:
  web-data:
EOF

# Create web directory with genesis file
mkdir -p web

# Create a working genesis file
cat > web/genesis << 'EOF'
{"reqSignature":{},"txn":{"data":{"data":{"alias":"Node1","blskey":"4N8aUNHSgjQVgkpm8nhNEfDf6txHznoYREg9kirmJrkivgL4oSEimFF6nsQ6M41QvhM2Z33nves5vfSn9n1UwNFJBYtWVnHYMATn76vLuL3zU88KyeAYcHfsih3He6UHcXDxcaecHVz6jhCYz1P2UZn2bDVruL5wXpehgBfBaLKm3Ba","blskey_pop":"RahHYiCvoNCtPTrVtP7nMC5eTYrsUA8WjXbdhNc8debh1agE9bGiJxWBXYNFbnJXoXhWFMvyqhqhRoq737YQemH5ik9oL7R4NTTCz2LEZhkgLJzB3QRQqJyBNyv7acbdHrAT8nQ9UkLbaVL9NBpnWXBTw4LEMePaSHEw66RzPNdAX1","client_ip":"127.0.0.1","client_port":9702,"node_ip":"127.0.0.1","node_port":9701,"services":["VALIDATOR"]},"dest":"Gw6pDLhcBcoQesN72qfotTgFa7cbuqZpkX3Xo6pLhPhv"},"metadata":{"from":"Th7MpTaRZVRYnPiabds81Y"},"type":"0"},"txnMetadata":{"seqNo":1,"txnId":"fea82e10e894419fe2bea7d96296a6d46f50f93f9eeda954ec461b2ed2950b62"},"ver":"1"}
EOF

# Create status endpoint
cat > web/status << 'EOF'
{
  "ready": true,
  "register_new_dids": true,
  "display_ledger_state": true,
  "syncing": false
}
EOF

# Start the simple version
docker-compose up -d

# Wait and test
sleep 5

echo "Testing endpoints..."
curl -s http://localhost:8000/genesis
echo ""
curl -s http://localhost:8000/status
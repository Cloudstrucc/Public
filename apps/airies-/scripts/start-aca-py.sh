#!/bin/bash

# Start ACA-Py agents V2
set -e

echo "🚀 Starting ACA-Py V2 agents..."

cd docker/aca-py

# Update endpoints with current IP
PUBLIC_IP=$(curl -s ifconfig.me || echo "localhost")
echo "📍 Using public IP: $PUBLIC_IP"

# Update docker-compose.yml with current IP
sed -i.bak "s/localhost:4000/${PUBLIC_IP}:4000/g" docker-compose.yml
sed -i.bak "s/localhost:4002/${PUBLIC_IP}:4002/g" docker-compose.yml

# Start ACA-Py V2 agents
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for ACA-Py V2 agents to be ready..."
sleep 30

# Check agent status
echo "🔍 Checking agent status..."
if curl -s -H "X-API-KEY: v2secretkey" http://localhost:4001/status > /dev/null; then
    echo "✅ ACA-Py Agent V2 is ready!"
    
    # Get agent DID
    AGENT_DID=$(curl -s -H "X-API-KEY: v2secretkey" http://localhost:4001/wallet/did/public | jq -r '.result.did' 2>/dev/null || echo "unknown")
    echo "🆔 Agent DID: $AGENT_DID"
    
    echo "🌐 Agent admin: http://${PUBLIC_IP}:4001/api/doc"
else
    echo "❌ ACA-Py Agent V2 is not responding. Check logs:"
    docker-compose logs acapyagent-v2
fi

if curl -s -H "X-API-KEY: v2secretkey" http://localhost:4003/status > /dev/null; then
    echo "✅ Mediator Agent V2 is ready!"
    
    # Get mediator DID
    MEDIATOR_DID=$(curl -s -H "X-API-KEY: v2secretkey" http://localhost:4003/wallet/did/public | jq -r '.result.did' 2>/dev/null || echo "unknown")
    echo "🆔 Mediator DID: $MEDIATOR_DID"
    
    echo "🌐 Mediator admin: http://${PUBLIC_IP}:4003/api/doc"
else
    echo "❌ Mediator Agent V2 is not responding. Check logs:"
    docker-compose logs mediator-v2
fi

# Restore original docker-compose.yml
mv docker-compose.yml.bak docker-compose.yml 2>/dev/null || true

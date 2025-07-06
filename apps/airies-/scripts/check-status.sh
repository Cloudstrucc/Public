#!/bin/bash

# Check status of all Aries V2 components
set -e

API_KEY=${API_KEY:-v2secretkey}

echo "🔍 Checking Aries Canada V2 infrastructure status..."
echo ""

# Check von-network V2
echo "📊 Von-Network V2 Status:"
if curl -s http://localhost:8000/status > /dev/null; then
    VON_STATUS=$(curl -s http://localhost:8000/status)
    echo "✅ Von-network V2 is running"
    echo "   Genesis: http://localhost:8000/genesis"
    echo "   Web UI: http://localhost:8000"
    echo "   Register DIDs: $(echo "$VON_STATUS" | jq -r '.register_new_dids // "unknown"')"
else
    echo "❌ Von-network V2 is not responding"
fi
echo ""

# Check ACA-Py Agent V2
echo "🤖 ACA-Py Agent V2 Status:"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:4001/status > /dev/null; then
    AGENT_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:4001/status)
    echo "✅ Agent V2 is running"
    echo "   Admin API: http://localhost:4001/api/doc"
    echo "   Version: $(echo "$AGENT_STATUS" | jq -r '.version // "unknown"')"
    echo "   Label: $(echo "$AGENT_STATUS" | jq -r '.label // "unknown"')"
    
    # Get agent DID
    AGENT_DID=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:4001/wallet/did/public 2>/dev/null | jq -r '.result.did // "none"')
    echo "   DID: $AGENT_DID"
else
    echo "❌ ACA-Py Agent V2 is not responding"
fi
echo ""

# Check Mediator V2
echo "🔗 Mediator V2 Status:"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:4003/status > /dev/null; then
    MEDIATOR_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:4003/status)
    echo "✅ Mediator V2 is running"
    echo "   Admin API: http://localhost:4003/api/doc"
    echo "   Version: $(echo "$MEDIATOR_STATUS" | jq -r '.version // "unknown"')"
    echo "   Label: $(echo "$MEDIATOR_STATUS" | jq -r '.label // "unknown"')"
    
    # Get mediator DID
    MEDIATOR_DID=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:4003/wallet/did/public 2>/dev/null | jq -r '.result.did // "none"')
    echo "   DID: $MEDIATOR_DID"
else
    echo "❌ Mediator V2 is not responding"
fi
echo ""

# Check Docker containers
echo "🐳 Docker Containers (V2):"
docker ps --filter "name=aries-v2\|von-v2" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

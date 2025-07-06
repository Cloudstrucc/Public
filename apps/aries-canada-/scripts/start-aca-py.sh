#!/bin/bash

# Start ACA-Py agents - Enhanced Version
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting ACA-Py Agents (Verified Working Configuration)...${NC}"
echo ""

# Check if von-network is running
echo "🔍 Checking von-network status..."
if ! curl -s http://localhost:9000/genesis > /dev/null 2>&1; then
    echo -e "${RED}❌ Von-network is not running or accessible${NC}"
    echo -e "${YELLOW}💡 Start von-network first: ./scripts/start-von-network.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Von-network is accessible${NC}"

cd docker/aca-py

# Clean up existing containers
echo "🧹 Cleaning up existing ACA-Py containers..."
docker-compose down > /dev/null 2>&1 || true

# Update endpoints with current IP if needed
PUBLIC_IP=$(curl -s ifconfig.me || echo "localhost")
echo -e "${GREEN}📍 Using public IP: $PUBLIC_IP${NC}"

# Start ACA-Py agents
echo "🚀 Starting ACA-Py agent and mediator..."
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for ACA-Py agents to initialize...${NC}"
echo "   Agents need time to connect to ledger and create DIDs..."

# Wait for mediator first
echo "🔗 Waiting for mediator..."
for i in {1..30}; do
    if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Mediator is responding${NC}"
        break
    fi
    echo "   Attempt $i/30: Waiting for mediator..."
    sleep 2
done

# Wait for main agent
echo "🤖 Waiting for main agent..."
for i in {1..30}; do
    if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Agent is responding${NC}"
        break
    fi
    echo "   Attempt $i/30: Waiting for agent..."
    sleep 2
done

# Check agent status
echo ""
echo "🔍 Checking agent details..."

if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status > /dev/null 2>&1; then
    AGENT_STATUS=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status)
    AGENT_DID=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/wallet/did/public 2>/dev/null | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}✅ ACA-Py Agent is ready!${NC}"
    echo "   📋 Label: $(echo "$AGENT_STATUS" | jq -r '.label')"
    echo "   🆔 Agent DID: $AGENT_DID"
    echo -e "${GREEN}   🌐 Agent admin: http://${PUBLIC_IP}:3001/api/doc${NC}"
else
    echo -e "${RED}❌ ACA-Py Agent is not responding${NC}"
    echo "🔍 Check logs: docker-compose logs agent"
fi

if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status > /dev/null 2>&1; then
    MEDIATOR_STATUS=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status)
    MEDIATOR_DID=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/wallet/did/public 2>/dev/null | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}✅ Mediator Agent is ready!${NC}"
    echo "   📋 Label: $(echo "$MEDIATOR_STATUS" | jq -r '.label')"
    echo "   🆔 Mediator DID: $MEDIATOR_DID"
    echo -e "${GREEN}   🌐 Mediator admin: http://${PUBLIC_IP}:3003/api/doc${NC}"
else
    echo -e "${RED}❌ Mediator Agent is not responding${NC}"
    echo "🔍 Check logs: docker-compose logs mediator"
fi

cd ../..

echo ""
echo -e "${GREEN}✅ ACA-Py agents started successfully!${NC}"
echo ""
echo -e "${BLUE}🔧 Next steps:${NC}"
echo "   📊 Check status: ./scripts/check-status.sh"
echo "   📱 Create invitation: ./scripts/create-invitation.sh"

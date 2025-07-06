#!/bin/bash

# Comprehensive Status Check for Aries Infrastructure
set -e

API_KEY=${API_KEY:-demo-admin-key}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Aries Infrastructure Status Check${NC}"
echo "========================================"
echo "$(date)"
echo ""

# Check Docker daemon
echo -e "${BLUE}🐳 Docker Status:${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Docker daemon: RUNNING${NC}"
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo "   📊 Version: $DOCKER_VERSION"
else
    echo -e "${RED}   ❌ Docker daemon: NOT RUNNING${NC}"
    echo -e "${YELLOW}   💡 Start Docker: sudo systemctl start docker${NC}"
    exit 1
fi

# Check Docker containers
echo ""
echo -e "${BLUE}🐳 Docker Containers:${NC}"
ARIES_CONTAINERS=$(docker ps -a --filter "name=von\|aries" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "")

if [ -n "$ARIES_CONTAINERS" ]; then
    echo "$ARIES_CONTAINERS"
else
    echo -e "${YELLOW}   ⚠️  No Aries containers found${NC}"
    echo -e "${YELLOW}   💡 Start the stack: ./scripts/start-aries-stack.sh${NC}"
fi
echo ""

# Check von-network status
echo -e "${BLUE}📊 Von-Network Status:${NC}"
if curl -s http://localhost:9000/status > /dev/null 2>&1; then
    VON_STATUS=$(curl -s http://localhost:9000/status 2>/dev/null || echo "{}")
    echo -e "${GREEN}   ✅ Von-network: RUNNING${NC}"
    echo "   🌐 Web interface: http://localhost:9000"
    echo "   🔗 Genesis endpoint: http://localhost:9000/genesis"
    
    # Check genesis file validity
    if curl -s http://localhost:9000/genesis | jq . > /dev/null 2>&1; then
        GENESIS_TXN_COUNT=$(curl -s http://localhost:9000/genesis | jq '. | length' 2>/dev/null || echo "unknown")
        echo -e "${GREEN}   ✅ Genesis file: VALID (${GENESIS_TXN_COUNT} transactions)${NC}"
    else
        echo -e "${RED}   ❌ Genesis file: INVALID${NC}"
    fi
    
    # Additional von-network info
    echo "   📊 Register DIDs: $(echo "$VON_STATUS" | jq -r '.register_new_dids // "unknown"')"
    echo "   📋 Ledger State: $(echo "$VON_STATUS" | jq -r '.ledger_state // "unknown"')"
else
    echo -e "${RED}   ❌ Von-network: NOT RUNNING${NC}"
    echo -e "${YELLOW}   💡 Start with: ./scripts/start-aries-stack.sh${NC}"
fi
echo ""

# Check main agent status
echo -e "${BLUE}🤖 Main Agent Status:${NC}"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/status > /dev/null 2>&1; then
    AGENT_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/status)
    
    # Get agent DID
    AGENT_DID_RESPONSE=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/wallet/did/public 2>/dev/null || echo "{}")
    AGENT_DID=$(echo "$AGENT_DID_RESPONSE" | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}   ✅ Agent: RUNNING${NC}"
    echo "   📋 Label: $(echo "$AGENT_STATUS" | jq -r '.label')"
    echo "   📊 Version: $(echo "$AGENT_STATUS" | jq -r '.version')"
    echo "   🆔 DID: $AGENT_DID"
    
    # Check DID status
    if [ "$AGENT_DID" != "pending" ] && [ "$AGENT_DID" != "null" ] && [ -n "$AGENT_DID" ]; then
        echo -e "${GREEN}   ✅ DID Status: CREATED (Agent has proper DID)${NC}"
    else
        echo -e "${YELLOW}   ⏳ DID Status: PENDING (Agent may still be initializing)${NC}"
    fi
    
    echo "   🌐 Admin API: http://localhost:3001/api/doc"
    echo "   🔗 Agent Endpoint: http://localhost:3000"
    
    # Check wallet status
    WALLET_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/wallet/did 2>/dev/null || echo "{}")
    WALLET_DID_COUNT=$(echo "$WALLET_STATUS" | jq '.results | length' 2>/dev/null || echo "0")
    echo "   💳 Wallet DIDs: $WALLET_DID_COUNT"
    
else
    echo -e "${RED}   ❌ Agent: NOT RUNNING${NC}"
    echo -e "${YELLOW}   💡 Check logs: cd docker/aca-py && docker-compose logs agent${NC}"
fi
echo ""

# Check mediator status
echo -e "${BLUE}🔗 Mediator Status:${NC}"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:3003/status > /dev/null 2>&1; then
    MEDIATOR_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3003/status)
    
    # Get mediator DID
    MEDIATOR_DID_RESPONSE=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3003/wallet/did/public 2>/dev/null || echo "{}")
    MEDIATOR_DID=$(echo "$MEDIATOR_DID_RESPONSE" | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}   ✅ Mediator: RUNNING${NC}"
    echo "   📋 Label: $(echo "$MEDIATOR_STATUS" | jq -r '.label')"
    echo "   🆔 DID: $MEDIATOR_DID"
    
    # Check mediator DID status
    if [ "$MEDIATOR_DID" != "pending" ] && [ "$MEDIATOR_DID" != "null" ] && [ -n "$MEDIATOR_DID" ]; then
        echo -e "${GREEN}   ✅ DID Status: CREATED (Mediator has proper DID)${NC}"
    else
        echo -e "${YELLOW}   ⏳ DID Status: PENDING (Mediator may still be initializing)${NC}"
    fi
    
    echo "   🌐 Admin API: http://localhost:3003/api/doc"
    echo "   🔗 Mediator Endpoint: http://localhost:3002"
else
    echo -e "${RED}   ❌ Mediator: NOT RUNNING${NC}"
    echo -e "${YELLOW}   💡 Check logs: cd docker/aca-py && docker-compose logs mediator${NC}"
fi
echo ""

# Check connections
echo -e "${BLUE}📱 Active Connections:${NC}"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/connections > /dev/null 2>&1; then
    CONNECTIONS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/connections)
    CONNECTION_COUNT=$(echo "$CONNECTIONS" | jq '.results | length' 2>/dev/null || echo "0")
    
    echo "   📊 Total connections: $CONNECTION_COUNT"
    
    if [ "$CONNECTION_COUNT" -gt 0 ]; then
        echo ""
        echo "   Active connections:"
        echo "$CONNECTIONS" | jq -r '.results[] | "   🔗 \(.their_label // "Unknown") (\(.state)) - ID: \(.connection_id)"' 2>/dev/null || echo "   Unable to parse connections"
    fi
else
    echo -e "${RED}   ❌ Cannot check connections (agent not responding)${NC}"
fi
echo ""

# Check credentials
echo -e "${BLUE}🎓 Credential Activity:${NC}"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/issue-credential/records > /dev/null 2>&1; then
    CREDENTIALS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/issue-credential/records)
    CRED_COUNT=$(echo "$CREDENTIALS" | jq '.results | length' 2>/dev/null || echo "0")
    
    echo "   📊 Total credential exchanges: $CRED_COUNT"
    
    if [ "$CRED_COUNT" -gt 0 ]; then
        echo ""
        echo "   Recent credential activities:"
        echo "$CREDENTIALS" | jq -r '.results[] | "   🎓 \(.state) - Exchange ID: \(.credential_exchange_id)"' 2>/dev/null | tail -5 || echo "   Unable to parse credentials"
    fi
else
    echo -e "${RED}   ❌ Cannot check credentials (agent not responding)${NC}"
fi
echo ""

# Check proof requests
echo -e "${BLUE}🔍 Proof Verification Activity:${NC}"
if curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/present-proof/records > /dev/null 2>&1; then
    PROOFS=$(curl -s -H "X-API-KEY: $API_KEY" http://localhost:3001/present-proof/records)
    PROOF_COUNT=$(echo "$PROOFS" | jq '.results | length' 2>/dev/null || echo "0")
    
    echo "   📊 Total proof exchanges: $PROOF_COUNT"
    
    if [ "$PROOF_COUNT" -gt 0 ]; then
        echo ""
        echo "   Recent proof activities:"
        echo "$PROOFS" | jq -r '.results[] | "   🔍 \(.state) - Exchange ID: \(.presentation_exchange_id)"' 2>/dev/null | tail -5 || echo "   Unable to parse proofs"
    fi
else
    echo -e "${RED}   ❌ Cannot check proofs (agent not responding)${NC}"
fi
echo ""

# System resources
echo -e "${BLUE}💻 System Resources:${NC}"
if command -v free > /dev/null 2>&1; then
    MEMORY_USAGE=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    echo "   💾 Memory usage: $MEMORY_USAGE"
fi

if command -v df > /dev/null 2>&1; then
    DISK_USAGE=$(df -h . | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')
    echo "   💿 Disk usage: $DISK_USAGE"
fi

if command -v uptime > /dev/null 2>&1; then
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    echo "   📊 Load average:$LOAD_AVG"
fi
echo ""

# Network connectivity
echo -e "${BLUE}🌐 Network Connectivity:${NC}"
if ping -c 1 google.com > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Internet connectivity: AVAILABLE${NC}"
else
    echo -e "${YELLOW}   ⚠️  Internet connectivity: LIMITED${NC}"
fi

# Check ports
PORTS_TO_CHECK=("3000" "3001" "3002" "3003" "9000")
echo "   🔌 Port status:"
for port in "${PORTS_TO_CHECK[@]}"; do
    if netstat -tuln 2>/dev/null | grep ":$port " > /dev/null; then
        echo -e "${GREEN}      ✅ Port $port: LISTENING${NC}"
    else
        echo -e "${RED}      ❌ Port $port: NOT LISTENING${NC}"
    fi
done
echo ""

# Quick actions
echo -e "${BLUE}🔧 Quick Actions:${NC}"
echo "   📱 Create invitation: ./scripts/create-invitation.sh"
echo "   🎓 Issue credential: ./scripts/issue-credential.sh <connection_id>"
echo "   🔍 Request proof: ./scripts/request-proof.sh <connection_id>"
echo "   🛑 Stop stack: ./scripts/stop-aries-stack.sh"
echo "   📋 View logs: cd docker/aca-py && docker-compose logs -f"
echo "   🧹 Clean restart: ./scripts/stop-aries-stack.sh && ./scripts/start-aries-stack.sh"
echo ""

# Configuration summary
echo -e "${BLUE}⚙️  Configuration Summary:${NC}"
echo "   🔑 API Key: $API_KEY"
echo "   🌐 Agent URL: http://localhost:3001"
echo "   🔗 Mediator URL: http://localhost:3003"
echo "   📊 Von-network URL: http://localhost:9000"
echo ""

echo -e "${GREEN}✅ Status check complete!${NC}"

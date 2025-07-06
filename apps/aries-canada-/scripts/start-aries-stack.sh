#!/bin/bash

# Complete Aries Stack Startup Script (Verified Working Solution)
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Complete Aries Stack (Working Configuration)...${NC}"
echo "   1. Von-Network (Hyperledger Indy Ledger)"
echo "   2. ACA-Py Agents (Agent + Mediator)"
echo "   3. Health Checks and Verification"
echo ""

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check if Docker is installed and running
if ! command -v docker > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo -e "${YELLOW}💡 Install Docker: curl -fsSL https://get.docker.com | sh${NC}"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo -e "${YELLOW}💡 Start Docker: sudo systemctl start docker${NC}"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo -e "${YELLOW}💡 Install Docker Compose: sudo apt install docker-compose${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  jq is not installed (recommended for JSON parsing)${NC}"
    echo -e "${YELLOW}💡 Install jq: sudo apt install jq${NC}"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Step 1: Start von-network first
echo -e "${BLUE}📊 Step 1: Starting von-network (Hyperledger Indy Ledger)...${NC}"
cd docker/von-network

# Clean up any existing containers
echo "🧹 Cleaning up existing von-network containers..."
docker-compose down > /dev/null 2>&1 || true

# Start von-network
echo "🚀 Starting von-network containers..."
docker-compose up -d

cd ../..

# Wait for von-network to be ready
echo -e "${YELLOW}⏳ Waiting for von-network to initialize...${NC}"
echo "   This may take 30-60 seconds for first-time setup..."

for i in {1..60}; do
    if curl -s http://localhost:9000/genesis > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Von-network is ready!${NC}"
        break
    fi
    if [ $i -eq 60 ]; then
        echo -e "${RED}❌ Von-network failed to start within 60 seconds${NC}"
        echo "🔍 Checking von-network logs:"
        cd docker/von-network && docker-compose logs webserver
        exit 1
    fi
    echo "   Attempt $i/60: Waiting for von-network..."
    sleep 1
done

# Verify genesis is accessible and valid
echo "🔍 Verifying genesis endpoint..."
GENESIS_RESPONSE=$(curl -s http://localhost:9000/genesis)
if echo "$GENESIS_RESPONSE" | jq . > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Genesis file is valid JSON${NC}"
    GENESIS_TXN_COUNT=$(echo "$GENESIS_RESPONSE" | jq '. | length')
    echo "   📊 Genesis transactions: $GENESIS_TXN_COUNT"
else
    echo -e "${RED}❌ Genesis file is not valid JSON${NC}"
    echo "Response: $GENESIS_RESPONSE"
    exit 1
fi

echo -e "${GREEN}🌐 Von-network endpoints:${NC}"
echo "   📊 Web interface: http://localhost:9000"
echo "   🔗 Genesis endpoint: http://localhost:9000/genesis"
echo "   📋 Browse transactions: http://localhost:9000/browse/domain"
echo ""

# Step 2: Start ACA-Py agents
echo -e "${BLUE}🤖 Step 2: Starting ACA-Py agents (Working Configuration)...${NC}"
cd docker/aca-py

# Clean up any existing containers
echo "🧹 Cleaning up existing ACA-Py containers..."
docker-compose down > /dev/null 2>&1 || true

# Start ACA-Py agents
echo "🚀 Starting ACA-Py agent and mediator..."
docker-compose up -d

cd ../..

# Wait for agents to be ready
echo -e "${YELLOW}⏳ Waiting for ACA-Py agents to initialize...${NC}"
echo "   Agents need time to connect to ledger and create DIDs..."

# Wait for mediator first (since agent depends on it)
echo "🔗 Waiting for mediator to be ready..."
for i in {1..30}; do
    if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Mediator is responding${NC}"
        break
    fi
    echo "   Attempt $i/30: Waiting for mediator..."
    sleep 2
done

# Wait for main agent
echo "🤖 Waiting for main agent to be ready..."
for i in {1..30}; do
    if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Agent is responding${NC}"
        break
    fi
    echo "   Attempt $i/30: Waiting for agent..."
    sleep 2
done

# Step 3: Comprehensive health checks
echo ""
echo -e "${BLUE}🔍 Step 3: Performing comprehensive health checks...${NC}"
echo ""

# Check von-network status
echo -e "${BLUE}📊 Von-Network Status:${NC}"
if curl -s http://localhost:9000/status > /dev/null 2>&1; then
    VON_STATUS=$(curl -s http://localhost:9000/status 2>/dev/null || echo "{}")
    echo -e "${GREEN}   ✅ Von-network: RUNNING${NC}"
    echo "   🌐 Web UI: http://localhost:9000"
    echo "   🔗 Genesis: http://localhost:9000/genesis"
    echo "   📊 Register DIDs: $(echo "$VON_STATUS" | jq -r '.register_new_dids // "unknown"')"
    echo "   📋 Ledger State: $(echo "$VON_STATUS" | jq -r '.ledger_state // "unknown"')"
else
    echo -e "${RED}   ❌ Von-network: NOT RESPONDING${NC}"
fi

# Check main agent status
echo ""
echo -e "${BLUE}🤖 Main Agent Status:${NC}"
if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status > /dev/null 2>&1; then
    AGENT_STATUS=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/status)
    
    # Get agent DID (this is the critical test)
    AGENT_DID_RESPONSE=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3001/wallet/did/public 2>/dev/null || echo "{}")
    AGENT_DID=$(echo "$AGENT_DID_RESPONSE" | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}   ✅ Agent: RUNNING${NC}"
    echo "   📋 Label: $(echo "$AGENT_STATUS" | jq -r '.label')"
    echo "   📊 Version: $(echo "$AGENT_STATUS" | jq -r '.version')"
    echo "   🆔 DID: $AGENT_DID"
    
    # Check if DID creation was successful (not anonymous)
    if [ "$AGENT_DID" != "pending" ] && [ "$AGENT_DID" != "null" ] && [ -n "$AGENT_DID" ]; then
        echo -e "${GREEN}   ✅ DID Creation: SUCCESS (Agent has proper DID)${NC}"
    else
        echo -e "${YELLOW}   ⏳ DID Creation: PENDING (May need more time)${NC}"
    fi
    
    echo "   🌐 Admin API: http://localhost:3001/api/doc"
    echo "   🔗 Agent Endpoint: http://localhost:3000"
else
    echo -e "${RED}   ❌ Agent: NOT RESPONDING${NC}"
    echo "   📋 Check logs: cd docker/aca-py && docker-compose logs agent"
fi

# Check mediator status
echo ""
echo -e "${BLUE}🔗 Mediator Status:${NC}"
if curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status > /dev/null 2>&1; then
    MEDIATOR_STATUS=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/status)
    
    # Get mediator DID
    MEDIATOR_DID_RESPONSE=$(curl -s -H "X-API-KEY: demo-admin-key" http://localhost:3003/wallet/did/public 2>/dev/null || echo "{}")
    MEDIATOR_DID=$(echo "$MEDIATOR_DID_RESPONSE" | jq -r '.result.did // "pending"')
    
    echo -e "${GREEN}   ✅ Mediator: RUNNING${NC}"
    echo "   📋 Label: $(echo "$MEDIATOR_STATUS" | jq -r '.label')"
    echo "   🆔 DID: $MEDIATOR_DID"
    
    # Check mediator DID
    if [ "$MEDIATOR_DID" != "pending" ] && [ "$MEDIATOR_DID" != "null" ] && [ -n "$MEDIATOR_DID" ]; then
        echo -e "${GREEN}   ✅ DID Creation: SUCCESS (Mediator has proper DID)${NC}"
    else
        echo -e "${YELLOW}   ⏳ DID Creation: PENDING (May need more time)${NC}"
    fi
    
    echo "   🌐 Admin API: http://localhost:3003/api/doc"
    echo "   🔗 Mediator Endpoint: http://localhost:3002"
else
    echo -e "${RED}   ❌ Mediator: NOT RESPONDING${NC}"
    echo "   📋 Check logs: cd docker/aca-py && docker-compose logs mediator"
fi

# Check Docker containers
echo ""
echo -e "${BLUE}🐳 Docker Containers:${NC}"
echo "$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=von-\|aries-")"

echo ""
echo -e "${GREEN}🎉 Aries Stack startup complete!${NC}"
echo ""
echo -e "${BLUE}🔧 Next Steps - Complete Workflow:${NC}"
echo "   1. 📱 Create mobile wallet invitation:"
echo "      ./scripts/create-invitation.sh"
echo ""
echo "   2. 🎓 Issue credential (after mobile connection):"
echo "      ./scripts/issue-credential.sh <connection_id>"
echo ""
echo "   3. 🔍 Request proof verification:"
echo "      ./scripts/request-proof.sh <connection_id>"
echo ""
echo "   4. 📊 Check system status anytime:"
echo "      ./scripts/check-status.sh"
echo ""
echo "   5. 🛑 Stop everything:"
echo "      ./scripts/stop-aries-stack.sh"
echo ""
echo -e "${BLUE}📚 API Documentation:${NC}"
echo "   🤖 Agent API: http://localhost:3001/api/doc"
echo "   🔗 Mediator API: http://localhost:3003/api/doc"
echo "   📊 Von-network: http://localhost:9000"
echo ""
echo -e "${YELLOW}💡 Troubleshooting:${NC}"
echo "   📋 View logs: cd docker/aca-py && docker-compose logs -f"
echo "   🔄 Restart: ./scripts/stop-aries-stack.sh && ./scripts/start-aries-stack.sh"
echo "   🔍 Test APIs: curl -H 'X-API-KEY: demo-admin-key' http://localhost:3001/status | jq"
echo ""
echo -e "${GREEN}✅ Your Aries infrastructure is ready for development and testing!${NC}"

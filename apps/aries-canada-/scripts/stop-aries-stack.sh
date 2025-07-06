#!/bin/bash

# Stop Aries Stack (Clean Shutdown)
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping Aries Stack...${NC}"
echo ""

# Stop ACA-Py agents first
echo -e "${BLUE}🤖 Stopping ACA-Py agents...${NC}"
if [ -d "docker/aca-py" ]; then
    cd docker/aca-py
    if docker-compose ps | grep -q aries; then
        echo "   Stopping agent and mediator containers..."
        docker-compose down
        echo -e "${GREEN}   ✅ ACA-Py agents stopped${NC}"
    else
        echo -e "${YELLOW}   ⚠️  ACA-Py containers were not running${NC}"
    fi
    cd ../..
else
    echo -e "${YELLOW}   ⚠️  ACA-Py directory not found${NC}"
fi

echo ""

# Stop von-network
echo -e "${BLUE}📊 Stopping von-network...${NC}"
if [ -d "docker/von-network" ]; then
    cd docker/von-network
    if docker-compose ps | grep -q von; then
        echo "   Stopping ledger containers..."
        docker-compose down
        echo -e "${GREEN}   ✅ Von-network stopped${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Von-network containers were not running${NC}"
    fi
    cd ../..
else
    echo -e "${YELLOW}   ⚠️  Von-network directory not found${NC}"
fi

echo ""

# Check for any remaining containers
echo -e "${BLUE}🐳 Checking for remaining Aries containers...${NC}"
REMAINING_CONTAINERS=$(docker ps -q --filter "name=aries\|von" 2>/dev/null || echo "")

if [ -n "$REMAINING_CONTAINERS" ]; then
    echo -e "${YELLOW}   ⚠️  Found remaining containers, stopping them...${NC}"
    docker stop $REMAINING_CONTAINERS
    docker rm $REMAINING_CONTAINERS
    echo -e "${GREEN}   ✅ Remaining containers cleaned up${NC}"
else
    echo -e "${GREEN}   ✅ No remaining containers found${NC}"
fi

echo ""
echo -e "${GREEN}✅ Aries Stack stopped successfully!${NC}"
echo ""
echo -e "${BLUE}🔧 Available Commands:${NC}"
echo "   🚀 Restart stack: ./scripts/start-aries-stack.sh"
echo "   📊 Check status: ./scripts/check-status.sh"
echo "   🧹 Clean up volumes: docker volume prune -f"
echo "   🗑️  Remove images: docker image prune -f"
echo ""
echo -e "${BLUE}💡 System Cleanup Options:${NC}"
echo "   Remove unused networks: docker network prune -f"
echo "   Remove unused volumes: docker volume prune -f"
echo "   Remove unused images: docker image prune -a -f"
echo "   Complete cleanup: docker system prune -a --volumes -f"

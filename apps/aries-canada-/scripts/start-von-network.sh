#!/bin/bash

# Start von-network (Hyperledger Indy ledger) - Enhanced Version
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting von-network (Hyperledger Indy Ledger)...${NC}"
echo ""

# Check prerequisites
if ! command -v docker-compose > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose not found${NC}"
    echo -e "${YELLOW}💡 Install: sudo apt install docker-compose${NC}"
    exit 1
fi

cd docker/von-network

# Clean up any existing containers
echo "🧹 Cleaning up existing von-network containers..."
docker-compose down > /dev/null 2>&1 || true

# Set environment variables
export IP=$(curl -s ifconfig.me || echo "localhost")
echo -e "${GREEN}📍 Using IP: $IP${NC}"

# Start von-network
echo "🚀 Starting von-network containers..."
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for von-network to be ready...${NC}"
echo "   This may take 30-60 seconds for first-time setup..."

for i in {1..60}; do
    if curl -s http://localhost:9000/genesis > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Von-network is ready!${NC}"
        break
    fi
    if [ $i -eq 60 ]; then
        echo -e "${RED}❌ Von-network failed to start${NC}"
        echo "🔍 Check logs:"
        docker-compose logs webserver
        exit 1
    fi
    echo "   Attempt $i/60: Waiting for von-network..."
    sleep 1
done

# Verify genesis endpoint
if curl -s http://localhost:9000/genesis | jq . > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Genesis endpoint is accessible and valid${NC}"
    echo -e "${GREEN}🌐 Genesis endpoint: http://localhost:9000/genesis${NC}"
    echo -e "${GREEN}🌐 Web interface: http://localhost:9000${NC}"
    echo -e "${GREEN}📋 Browse transactions: http://localhost:9000/browse/domain${NC}"
else
    echo -e "${RED}❌ Genesis endpoint is not accessible or invalid${NC}"
    docker-compose logs webserver
    exit 1
fi

cd ../..

echo ""
echo -e "${GREEN}✅ Von-network started successfully!${NC}"
echo ""
echo -e "${BLUE}🔧 Next step:${NC}"
echo "   Start ACA-Py agents: ./scripts/start-aca-py.sh"

#!/bin/bash

# Complete Docker cleanup for port conflicts
echo "🧹 Cleaning up Docker containers and resolving port conflicts..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Checking for port conflicts...${NC}"

# Check what's using the von-network ports
for port in 9000 9701 9702 9703 9704 9705 9706 9707 9708; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port $port is in use${NC}"
        lsof -i :$port
    fi
done

echo ""
echo -e "${BLUE}🛑 Stopping all containers...${NC}"

# Stop all containers (not just von-network ones)
docker stop $(docker ps -q) 2>/dev/null || echo "No running containers to stop"

echo -e "${BLUE}🗑️  Removing all containers...${NC}"

# Remove all containers
docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"

echo -e "${BLUE}🧹 Cleaning up networks...${NC}"

# Remove custom networks
docker network rm $(docker network ls -q --filter type=custom) 2>/dev/null || echo "No custom networks to remove"

echo -e "${BLUE}💾 Cleaning up volumes (optional)...${NC}"

# Optionally remove volumes (this will delete data)
read -p "Remove Docker volumes? This will delete all data (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume rm $(docker volume ls -q) 2>/dev/null || echo "No volumes to remove"
    echo -e "${GREEN}✅ Volumes removed${NC}"
else
    echo -e "${YELLOW}⏭️  Volumes kept${NC}"
fi

echo -e "${BLUE}🔄 Pruning Docker system...${NC}"

# Clean up everything else
docker system prune -f

echo ""
echo -e "${GREEN}✅ Docker cleanup complete!${NC}"
echo ""
echo -e "${BLUE}🔍 Verifying ports are free...${NC}"

# Check ports are now free
for port in 9000 9701 9702 9703 9704 9705 9706 9707 9708; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "${RED}❌ Port $port still in use${NC}"
        lsof -i :$port
    else
        echo -e "${GREEN}✅ Port $port is free${NC}"
    fi
done

echo ""
echo -e "${GREEN}🚀 Ready to start fresh!${NC}"
echo ""
echo "Next steps:"
echo "1. 🚀 Start the Aries stack: ./scripts/start-aries-stack.sh"
echo "2. 📊 Check status: ./scripts/check-status.sh"
echo "3. 📱 Create invitation: ./scripts/create-invitation.sh"

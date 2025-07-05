#!/bin/bash

# Cleanup script for Aries Canada project (V2 - Safe cleanup)
# This script removes all directories, files, and Docker resources created by setup-aries-project.sh
#
# USAGE:
# 1. Make executable: chmod +x cleanup-aries-project.sh
# 2. Run with confirmation: ./cleanup-aries-project.sh
# 3. Run without confirmation: ./cleanup-aries-project.sh --force
#
# SAFETY: Only removes V2 resources to avoid conflicts with existing setups

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

echo -e "${RED}🧹 Aries Canada V2 Project Cleanup${NC}"
echo -e "${YELLOW}⚠️  This will remove ALL files and Docker resources created by the setup script${NC}"
echo ""

# Function to ask for confirmation
confirm() {
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}$1${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Skipping...${NC}"
        return 1
    fi
    return 0
}

# Function to safely remove directory
safe_remove_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}Removing directory: $dir${NC}"
        rm -rf "$dir"
    else
        echo -e "${YELLOW}Directory not found: $dir${NC}"
    fi
}

# Function to safely remove file
safe_remove_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}Removing file: $file${NC}"
        rm -f "$file"
    else
        echo -e "${YELLOW}File not found: $file${NC}"
    fi
}

echo -e "${BLUE}📊 Checking what will be removed...${NC}"
echo ""

# Check for Docker resources
echo -e "${BLUE}🐳 Docker Resources (V2):${NC}"
docker ps -a --filter "name=aries-v2\|von-v2" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "No V2 containers found"
docker network ls --filter "name=aries-v2\|von-v2" --format "table {{.Name}}" 2>/dev/null || echo "No V2 networks found"
docker volume ls --filter "name=v2" --format "table {{.Name}}" 2>/dev/null || echo "No V2 volumes found"
echo ""

# Check for directories
echo -e "${BLUE}📁 Directories to remove:${NC}"
for dir in infra scripts .github docker docs tests; do
    if [[ -d "$dir" ]]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ (not found)"
    fi
done
echo ""

# Check for files
echo -e "${BLUE}📄 Files to remove:${NC}"
for file in README.md cleanup-aries-project.sh; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (not found)"
    fi
done
echo ""

# Confirm overall cleanup
if ! confirm "🗑️  Remove ALL Aries Canada V2 project files and Docker resources?"; then
    echo -e "${GREEN}✅ Cleanup cancelled. No changes made.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}🧹 Starting cleanup...${NC}"
echo ""

# Stop and remove Docker containers
if confirm "🛑 Stop and remove V2 Docker containers?"; then
    echo -e "${BLUE}Stopping V2 containers...${NC}"
    
    # Stop containers
    docker stop $(docker ps -q --filter "name=aries-v2\|von-v2") 2>/dev/null || echo "No running V2 containers to stop"
    
    # Remove containers
    docker rm $(docker ps -aq --filter "name=aries-v2\|von-v2") 2>/dev/null || echo "No V2 containers to remove"
    
    echo -e "${GREEN}✅ V2 containers cleaned up${NC}"
fi

# Remove Docker networks
if confirm "🌐 Remove V2 Docker networks?"; then
    echo -e "${BLUE}Removing V2 networks...${NC}"
    
    # Remove custom networks
    docker network rm aries-v2-network 2>/dev/null || echo "aries-v2-network not found"
    docker network rm von-v2 2>/dev/null || echo "von-v2 network not found"
    
    echo -e "${GREEN}✅ V2 networks cleaned up${NC}"
fi

# Remove Docker volumes
if confirm "💾 Remove V2 Docker volumes?"; then
    echo -e "${BLUE}Removing V2 volumes...${NC}"
    
    # Remove V2 volumes
    docker volume rm $(docker volume ls -q --filter "name=v2") 2>/dev/null || echo "No V2 volumes to remove"
    
    echo -e "${GREEN}✅ V2 volumes cleaned up${NC}"
fi

# Remove directories
if confirm "📁 Remove project directories?"; then
    echo -e "${BLUE}Removing directories...${NC}"
    
    safe_remove_dir "infra"
    safe_remove_dir "scripts"
    safe_remove_dir ".github"
    safe_remove_dir "docker"
    safe_remove_dir "docs"
    safe_remove_dir "tests"
    
    echo -e "${GREEN}✅ Directories cleaned up${NC}"
fi

# Remove files
if confirm "📄 Remove project files?"; then
    echo -e "${BLUE}Removing files...${NC}"
    
    safe_remove_file "README.md"
    
    echo -e "${GREEN}✅ Files cleaned up${NC}"
fi

# Remove cleanup script itself (optional)
if confirm "🗑️  Remove cleanup script itself?"; then
    echo -e "${BLUE}Removing cleanup script...${NC}"
    echo -e "${YELLOW}Note: This script will be deleted after completion${NC}"
    
    # Schedule self-deletion
    (sleep 2 && rm -f "$0") &
    
    echo -e "${GREEN}✅ Cleanup script scheduled for removal${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "  🐳 Docker containers, networks, and volumes removed"
echo "  📁 Project directories removed"
echo "  📄 Project files removed"
echo "  🧹 System cleaned up"
echo ""
echo -e "${GREEN}✅ Your system is now clean of Aries Canada V2 project files${NC}"
echo -e "${YELLOW}💡 You can safely run the setup script again if needed${NC}"

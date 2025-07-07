#!/bin/bash

echo "🧹 Cleaning up Docker containers and port conflicts..."

# Stop all running containers
echo "🛑 Stopping all containers..."
docker stop $(docker ps -q) 2>/dev/null || echo "No containers to stop"

# Remove all containers
echo "🗑️  Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"

# Remove networks
echo "🌐 Cleaning networks..."
docker network prune -f

# Check if ports are free
echo "🔍 Checking port status..."
for port in 9000 9701 9702 9703 9704 9705 9706 9707 9708; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo "❌ Port $port still in use"
    else
        echo "✅ Port $port is free"
    fi
done

echo "✅ Cleanup complete!"

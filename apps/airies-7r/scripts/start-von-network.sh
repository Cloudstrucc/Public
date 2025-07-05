#!/bin/bash

# Start von-network (Hyperledger Indy ledger) V2
set -e

echo "🚀 Starting von-network V2..."

cd docker/von-network

# Set environment variables
export IP=$(curl -s ifconfig.me || echo "localhost")
echo "📍 Using IP: $IP"

# Start von-network V2
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for von-network V2 to be ready..."
sleep 30

# Check if genesis endpoint is accessible
if curl -s http://localhost:8000/genesis > /dev/null; then
    echo "✅ Von-network V2 is ready!"
    echo "🌐 Genesis endpoint: http://localhost:8000/genesis"
    echo "🌐 Web interface: http://localhost:8000"
else
    echo "❌ Von-network V2 is not responding. Check logs:"
    docker-compose logs
    exit 1
fi

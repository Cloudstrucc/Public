#!/bin/bash
# Production Deployment Script

set -e

echo "🚀 Deploying AI-Powered E-commerce Platform..."

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if [ ! -f .env ]; then
    echo "❌ .env file not found. Please configure your environment first."
    exit 1
fi

# Build and deploy
echo "🔨 Building application..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 60

echo "🏥 Performing health checks..."
if curl -f http://localhost:7001/health > /dev/null 2>&1; then
    echo "✅ API is healthy"
else
    echo "❌ API health check failed"
    exit 1
fi

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed"
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo ""
echo "📱 Access your applications:"
echo "   Frontend:    http://localhost:5000"
echo "   API:         http://localhost:7001"
echo "   API Docs:    http://localhost:7001/swagger"
echo "   Monitoring:  http://localhost:3000"
echo ""
echo "🛠️  Management commands:"
echo "   make logs    - View logs"
echo "   make status  - Check status"
echo "   make backup  - Backup database"

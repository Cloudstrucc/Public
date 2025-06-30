#!/bin/bash
# Deployment script for AI-Powered E-commerce Platform

set -e

echo "🚀 Deploying AI-Powered E-commerce Platform..."

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    exit 1
fi

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating environment file..."
    cp .env.example .env
    echo "⚠️  Please update .env with your actual values before continuing"
    exit 1
fi

# Build and start services
echo "🔨 Building services..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 60

# Health check
echo "🏥 Performing health checks..."
if curl -f http://localhost:7001/health > /dev/null 2>&1; then
    echo "✅ API is healthy"
else
    echo "❌ API health check failed"
    exit 1
fi

if curl -f http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed"
    exit 1
fi

echo "🎉 Deployment completed successfully!"
echo "📱 Access your platform at http://localhost:5001"

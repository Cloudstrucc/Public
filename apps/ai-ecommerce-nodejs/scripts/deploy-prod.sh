#!/bin/bash
# Production deployment script

echo "🚀 Deploying to production..."

# Build production images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

# Start production services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "✅ Production deployment completed!"

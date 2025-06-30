#!/bin/bash
# Development setup script for AI E-commerce Platform

echo "🚀 Setting up development environment..."

# Install Node.js dependencies
echo "📦 Installing Express.js API dependencies..."
cd express-api && npm install && cd ..

echo "📦 Installing Next.js frontend dependencies..."
cd nextjs-frontend && npm install && cd ..

# Install Python dependencies
echo "🐍 Installing Python agent dependencies..."
cd python-agent && pip install -r requirements.txt && cd ..

echo "✅ Development environment setup completed!"
echo "Run 'make dev' to start all services"

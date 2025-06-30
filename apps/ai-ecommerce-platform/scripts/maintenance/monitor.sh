#!/bin/bash
# Monitoring script for AI-Powered E-commerce Platform

echo "📊 AI-Powered E-commerce Platform Status Report"
echo "================================================="

# System Information
echo "🖥️  System Information:"
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo

# Docker Status
echo "🐳 Docker Services:"
docker-compose ps
echo

# Container Health
echo "🏥 Health Checks:"
services=("ecommerce-dotnet-api:7001" "ecommerce-blazor-frontend:5001")
for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    if curl -f http://localhost:$port/health > /dev/null 2>&1; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name health check failed"
    fi
done

# Database Status
echo
echo "🐘 PostgreSQL Status:"
if docker exec ecommerce-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
    # Get product count
    PRODUCT_COUNT=$(docker exec ecommerce-postgres psql -U postgres -d EcommerceAI -t -c "SELECT COUNT(*) FROM \"Products\";" 2>/dev/null | xargs || echo "0")
    echo "📦 Products in database: $PRODUCT_COUNT"
else
    echo "❌ PostgreSQL is not ready"
fi

# Resource Usage
echo
echo "💾 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo
echo "📋 Recent Agent Activity (last 10 lines):"
docker logs ecommerce-python-agent --tail 10 2>/dev/null || echo "Agent logs not available"

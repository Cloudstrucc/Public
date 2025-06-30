#!/bin/bash
# Health check script for all services

echo "🏥 Performing comprehensive health checks..."

# Check API health
echo -n "Express.js API: "
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Frontend health
echo -n "Next.js Frontend: "
if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Database health
echo -n "PostgreSQL Database: "
if docker exec ecommerce-postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Redis health
echo -n "Redis Cache: "
if docker exec ecommerce-redis redis-cli -a RedisPass123! ping > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

# Check Python Agent health
echo -n "Python AI Agent: "
if docker logs ecommerce-python-agent 2>&1 | grep -q "Starting Node.js AI Agent System"; then
    echo "✅ Running"
else
    echo "❌ Not running"
fi

echo ""
echo "📊 Service Status:"
docker-compose ps

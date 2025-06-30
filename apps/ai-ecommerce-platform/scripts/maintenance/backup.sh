#!/bin/bash
# Backup script for AI-Powered E-commerce Platform

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "💾 Creating backup..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup PostgreSQL database
echo "📊 Backing up PostgreSQL database..."
docker exec ecommerce-postgres pg_dump -U postgres -d EcommerceAI > $BACKUP_DIR/postgres_backup_$TIMESTAMP.sql

# Backup application logs
echo "📋 Backing up application logs..."
tar -czf $BACKUP_DIR/logs_backup_$TIMESTAMP.tar.gz \
    python-agent/logs \
    dotnet-api/logs \
    blazor-frontend/logs \
    2>/dev/null || echo "Some logs directories may not exist yet"

# Backup configuration
echo "⚙️  Backing up configuration..."
tar -czf $BACKUP_DIR/config_backup_$TIMESTAMP.tar.gz \
    .env \
    docker-compose.yml \
    docker-compose.prod.yml \
    monitoring/

echo "✅ Backup completed successfully!"
echo "📁 Backup files created in $BACKUP_DIR/"
ls -la $BACKUP_DIR/*$TIMESTAMP*

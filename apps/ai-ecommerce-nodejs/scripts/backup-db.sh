#!/bin/bash
# Database backup script

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="ecommerce_backup_${TIMESTAMP}.sql"

mkdir -p $BACKUP_DIR

echo "💾 Creating PostgreSQL backup..."
docker exec ecommerce-postgres pg_dump -U postgres -d EcommerceAI > $BACKUP_DIR/$BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Backup created: $BACKUP_DIR/$BACKUP_FILE"
    
    # Compress backup
    gzip $BACKUP_DIR/$BACKUP_FILE
    echo "✅ Backup compressed: $BACKUP_DIR/$BACKUP_FILE.gz"
    
    # Keep only last 10 backups
    cd $BACKUP_DIR
    ls -t *.gz | tail -n +11 | xargs -r rm
    echo "📁 Cleaned up old backups (keeping 10 most recent)"
else
    echo "❌ Backup failed!"
    exit 1
fi

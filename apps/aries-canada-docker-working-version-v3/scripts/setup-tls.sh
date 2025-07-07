#!/bin/bash

# Setup TLS certificates for Aries agents
set -e

DOMAIN=${DOMAIN:-yourdomain.ca}
EMAIL=${EMAIL:-admin@yourdomain.ca}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔒 Setting up TLS certificates for Aries agents...${NC}"
echo "📧 Email: $EMAIL"
echo "🌐 Domain: $DOMAIN"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  This script needs to run with sudo for certificate installation${NC}"
    echo "Rerun with: sudo -E $0"
    exit 1
fi

# Install certbot
echo -e "${BLUE}📦 Installing certbot...${NC}"
apt update
apt install -y certbot nginx

# Stop services that might use ports 80/443
echo -e "${BLUE}⏹️  Stopping services on ports 80/443...${NC}"
systemctl stop apache2 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true

# Get certificates
echo -e "${BLUE}📜 Obtaining certificates for Aries endpoints...${NC}"
certbot certonly --standalone \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  -d "agent.$DOMAIN" \
  -d "mediator.$DOMAIN" \
  -d "ledger.$DOMAIN"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ TLS certificates obtained successfully!${NC}"
    echo "📁 Certificates location: /etc/letsencrypt/live/"
    echo ""
    
    # Create nginx configuration
    echo -e "${BLUE}🔧 Creating nginx configuration...${NC}"
    
    cat > /etc/nginx/sites-available/aries-agents << EOF
# Aries Agent (Port 3000 -> HTTPS)
server {
    listen 443 ssl;
    server_name agent.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/agent.$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/agent.$DOMAIN/privkey.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Aries Mediator (Port 3002 -> HTTPS)
server {
    listen 443 ssl;
    server_name mediator.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/mediator.$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mediator.$DOMAIN/privkey.pem;
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Von-Network Ledger (Port 9000 -> HTTPS)
server {
    listen 443 ssl;
    server_name ledger.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/ledger.$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ledger.$DOMAIN/privkey.pem;
    
    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name agent.$DOMAIN mediator.$DOMAIN ledger.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

#!/bin/bash

# Setup TLS certificates for Aries agents
set -e

DOMAIN=${DOMAIN:-yourdomain.ca}
EMAIL=${EMAIL:-admin@yourdomain.ca}

echo "🔒 Setting up TLS certificates..."
echo "📧 Email: $EMAIL"
echo "🌐 Domain: $DOMAIN"

# Install certbot
echo "📦 Installing certbot..."
sudo apt update
sudo apt install -y certbot

# Stop services that might use ports 80/443
echo "⏹️  Stopping services on ports 80/443..."
sudo systemctl stop apache2 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true

# Get certificates
echo "📜 Obtaining certificates..."
sudo certbot certonly --standalone \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  -d "agent.$DOMAIN" \
  -d "mediator.$DOMAIN"

if [ $? -eq 0 ]; then
    echo "✅ TLS certificates obtained successfully!"
    echo "📁 Certificates location: /etc/letsencrypt/live/"
    echo ""
    echo "🔧 Next steps:"
    echo "1. Configure your reverse proxy (nginx/apache)"
    echo "2. Update ACA-Py endpoints to use HTTPS"
    echo "3. Set up automatic renewal"
else
    echo "❌ Failed to obtain certificates"
    echo "💡 Make sure:"
    echo "   - Domain DNS points to this server"
    echo "   - Ports 80/443 are open in firewall"
    echo "   - No other service is using port 80"
fi

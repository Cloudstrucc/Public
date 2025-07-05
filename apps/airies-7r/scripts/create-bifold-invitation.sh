#!/bin/bash

# Create invitation for Bifold wallet connection V2
set -e

API_KEY=${API_KEY:-v2secretkey}
AGENT_URL=${AGENT_URL:-http://localhost:4001}

echo "📱 Creating Bifold wallet invitation V2..."

# Create invitation
INVITATION=$(curl -s -X POST "${AGENT_URL}/connections/create-invitation" \
  -H "X-API-KEY: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "alias": "bifold-user",
    "auto_accept": true,
    "multi_use": false,
    "public": false
  }')

if [ $? -eq 0 ] && [ -n "$INVITATION" ]; then
    echo "✅ Invitation created successfully!"
    echo ""
    echo "📋 Invitation Details:"
    echo "$INVITATION" | jq '.'
    echo ""
    
    # Extract invitation URL
    INVITATION_URL=$(echo "$INVITATION" | jq -r '.invitation_url' 2>/dev/null)
    if [ "$INVITATION_URL" != "null" ] && [ -n "$INVITATION_URL" ]; then
        echo "🔗 Invitation URL:"
        echo "$INVITATION_URL"
        echo ""
        echo "📱 To connect with Bifold:"
        echo "1. Open Bifold mobile app"
        echo "2. Tap 'Scan QR Code' or 'Add Connection'"
        echo "3. Scan the QR code or paste the invitation URL"
        
        # Generate QR code if qrencode is available
        if command -v qrencode > /dev/null; then
            echo ""
            echo "📊 QR Code:"
            qrencode -t ANSI "$INVITATION_URL"
        else
            echo ""
            echo "💡 Install qrencode to display QR code: sudo apt install qrencode"
        fi
    fi
else
    echo "❌ Failed to create invitation"
    echo "Response: $INVITATION"
    exit 1
fi

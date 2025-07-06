#!/bin/bash

# Create Connection Invitation for Mobile Wallets (Complete Process)
set -e

API_KEY=${API_KEY:-demo-admin-key}
AGENT_URL=${AGENT_URL:-http://localhost:3001}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📱 Creating Connection Invitation for Mobile Wallet...${NC}"
echo ""

# Check if agent is running
echo "🔍 Checking agent status..."
if ! curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/status" > /dev/null 2>&1; then
    echo -e "${RED}❌ Agent is not running or not accessible at $AGENT_URL${NC}"
    echo -e "${YELLOW}💡 Start the stack first: ./scripts/start-aries-stack.sh${NC}"
    exit 1
fi

# Get agent info
AGENT_INFO=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/status")
AGENT_LABEL=$(echo "$AGENT_INFO" | jq -r '.label // "Unknown Agent"')
AGENT_VERSION=$(echo "$AGENT_INFO" | jq -r '.version // "unknown"')
AGENT_DID=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/wallet/did/public" 2>/dev/null | jq -r '.result.did // "unknown"')

echo -e "${GREEN}🤖 Agent Information:${NC}"
echo "   📋 Label: $AGENT_LABEL"
echo "   📊 Version: $AGENT_VERSION"
echo "   🆔 DID: $AGENT_DID"
echo ""

# Create invitation
echo "📤 Creating connection invitation..."
INVITATION_RESPONSE=$(curl -s -X POST "$AGENT_URL/connections/create-invitation" \
  -H "X-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "alias": "mobile-wallet-user",
    "auto_accept": true,
    "multi_use": false,
    "public": false
  }')

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to create invitation${NC}"
    exit 1
fi

# Extract invitation details
CONNECTION_ID=$(echo "$INVITATION_RESPONSE" | jq -r '.connection_id // "unknown"')
INVITATION_URL=$(echo "$INVITATION_RESPONSE" | jq -r '.invitation_url // ""')
INVITATION=$(echo "$INVITATION_RESPONSE" | jq -r '.invitation // {}')

if [ "$INVITATION_URL" = "" ] || [ "$INVITATION_URL" = "null" ]; then
    echo -e "${RED}❌ Failed to get invitation URL${NC}"
    echo "Response: $INVITATION_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ Invitation created successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Invitation Details:${NC}"
echo "   🆔 Connection ID: $CONNECTION_ID"
echo "   🔗 Invitation URL: $INVITATION_URL"
echo ""

# Save invitation to file
INVITATION_FILE="invitation-$(date +%Y%m%d-%H%M%S).json"
echo "$INVITATION_RESPONSE" | jq '.' > "$INVITATION_FILE"
echo -e "${GREEN}💾 Invitation saved to: $INVITATION_FILE${NC}"
echo ""

# Display mobile wallet instructions
echo -e "${BLUE}📱 Mobile Wallet Instructions:${NC}"
echo "   1. Open your Aries-compatible wallet app:"
echo "      • Bifold Wallet (iOS/Android)"
echo "      • BC Wallet (British Columbia)"
echo "      • Connect.me (Evernym)"
echo "      • Trinsic Wallet"
echo "      • Any other Aries RFC-compliant wallet"
echo ""
echo "   2. Choose one of these options:"
echo "      • 'Scan QR Code' or 'Add Connection'"
echo "      • 'Receive Invitation' or similar"
echo ""
echo "   3. Scan the QR code below OR paste the invitation URL"
echo ""

# Generate QR code if qrencode is available
if command -v qrencode > /dev/null 2>&1; then
    echo -e "${BLUE}📊 QR Code:${NC}"
    qrencode -t ANSI256 "$INVITATION_URL"
    echo ""
else
    echo -e "${YELLOW}💡 Install qrencode for QR code display:${NC}"
    echo "   Ubuntu/Debian: sudo apt install qrencode"
    echo "   macOS: brew install qrencode"
    echo ""
fi

echo -e "${BLUE}🔗 Or copy this invitation URL:${NC}"
echo "$INVITATION_URL"
echo ""

# Monitor connection establishment
echo -e "${YELLOW}⏳ Monitoring connection establishment...${NC}"
echo "   Connection ID: $CONNECTION_ID"
echo "   Press Ctrl+C to stop monitoring"
echo ""

# Real-time connection monitoring
CONNECTED=false
for i in {1..120}; do  # Monitor for 4 minutes
    sleep 1
    
    # Get connection status
    CONNECTION_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/connections/$CONNECTION_ID" 2>/dev/null || echo "{}")
    STATE=$(echo "$CONNECTION_STATUS" | jq -r '.state // "unknown"')
    
    case $STATE in
        "invitation")
            if [ $((i % 10)) -eq 0 ]; then  # Update every 10 seconds
                echo "   ⏳ Status: Invitation sent, waiting for mobile wallet scan..."
            fi
            ;;
        "request")
            echo -e "${YELLOW}   🔄 Status: Connection request received from wallet...${NC}"
            ;;
        "response")
            echo -e "${YELLOW}   🔄 Status: Connection response sent to wallet...${NC}"
            ;;
        "active")
            THEIR_LABEL=$(echo "$CONNECTION_STATUS" | jq -r '.their_label // "Mobile Wallet"')
            echo -e "${GREEN}   ✅ Status: Connection established successfully!${NC}"
            echo -e "${GREEN}   📱 Connected to: $THEIR_LABEL${NC}"
            CONNECTED=true
            break
            ;;
        "error")
            echo -e "${RED}   ❌ Status: Connection error occurred${NC}"
            echo "   Connection details: $CONNECTION_STATUS"
            break
            ;;
        *)
            if [ $((i % 30)) -eq 0 ]; then  # Update every 30 seconds for unknown states
                echo "   ⏳ Status: $STATE (waiting... $i/120 seconds)"
            fi
            ;;
    esac
done

echo ""
if [ "$CONNECTED" = true ]; then
    echo -e "${GREEN}🎉 Mobile wallet connection successful!${NC}"
    echo ""
    echo -e "${BLUE}🔧 Next Steps:${NC}"
    echo "   1. 🎓 Issue a credential to the mobile wallet:"
    echo "      ./scripts/issue-credential.sh $CONNECTION_ID"
    echo ""
    echo "   2. 🔍 Request proof verification from the wallet:"
    echo "      ./scripts/request-proof.sh $CONNECTION_ID"
    echo ""
    echo "   3. 📊 View connection details:"
    echo "      curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/connections/$CONNECTION_ID | jq"
    echo ""
    echo "   4. 📋 List all connections:"
    echo "      curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/connections | jq '.results[]'"
    echo ""
else
    echo -e "${YELLOW}⏰ Connection monitoring timeout after 2 minutes${NC}"
    echo ""
    echo -e "${BLUE}💡 Manual connection check:${NC}"
    echo "   Check connection status:"
    echo "   curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/connections/$CONNECTION_ID | jq"
    echo ""
    echo "   The invitation is still valid. Try scanning again or check:"
    echo "   • Mobile wallet app is Aries-compatible"
    echo "   • Network connectivity from mobile device"
    echo "   • Invitation URL is complete and unmodified"
    echo ""
fi

echo -e "${BLUE}📱 Supported Mobile Wallets:${NC}"
echo "   • Bifold Wallet: https://github.com/hyperledger/aries-mobile-agent-react-native"
echo "   • BC Wallet: Available in app stores"
echo "   • Connect.me: https://www.evernym.com/"
echo "   • Trinsic Wallet: https://trinsic.id/"
echo ""
echo -e "${GREEN}✅ Invitation process complete!${NC}"

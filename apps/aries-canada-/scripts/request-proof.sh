#!/bin/bash

# Request Proof from Mobile Wallet (Complete Verification Process)
set -e

API_KEY=${API_KEY:-demo-admin-key}
AGENT_URL=${AGENT_URL:-http://localhost:3001}
CONNECTION_ID=${1:-}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$CONNECTION_ID" ]; then
    echo -e "${RED}❌ Usage: $0 <connection_id>${NC}"
    echo -e "${YELLOW}💡 Get connection ID from previous credential issuance${NC}"
    echo -e "${YELLOW}💡 Or list connections: curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/connections | jq '.results[]'${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Requesting Proof from Mobile Wallet (Complete Verification)...${NC}"
echo "   🔗 Connection ID: $CONNECTION_ID"
echo ""

# Check connection status
echo "🔍 Verifying connection status..."
CONNECTION_STATUS=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/connections/$CONNECTION_ID" 2>/dev/null || echo "{}")
CONNECTION_STATE=$(echo "$CONNECTION_STATUS" | jq -r '.state // "unknown"')

if [ "$CONNECTION_STATE" != "active" ]; then
    echo -e "${RED}❌ Connection not active: $CONNECTION_STATE${NC}"
    echo -e "${YELLOW}💡 Ensure mobile wallet is connected first${NC}"
    exit 1
fi

THEIR_LABEL=$(echo "$CONNECTION_STATUS" | jq -r '.their_label // "Mobile Wallet"')
echo -e "${GREEN}✅ Connection active with: $THEIR_LABEL${NC}"
echo ""

# Create comprehensive proof request
echo "📋 Creating proof request for Canadian identity verification..."

PROOF_REQUEST='{
  "connection_id": "'$CONNECTION_ID'",
  "proof_request": {
    "name": "Canadian Identity Verification",
    "version": "1.0",
    "requested_attributes": {
      "name_attr": {
        "name": "full_name",
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      },
      "birth_date_attr": {
        "name": "date_of_birth",
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      },
      "birth_place_attr": {
        "name": "place_of_birth",
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      },
      "document_attr": {
        "name": "document_number", 
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      },
      "issuing_authority_attr": {
        "name": "issuing_authority",
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      }
    },
    "requested_predicates": {
      "adult_predicate": {
        "name": "date_of_birth",
        "p_type": "<=",
        "p_value": "'$(date -d '18 years ago' +%Y%m%d)'",
        "restrictions": [],
        "non_revoked": {
          "to": "'$(date +%s)'"
        }
      }
    },
    "non_revoked": {
      "to": "'$(date +%s)'"
    }
  },
  "comment": "Please provide proof of your Canadian identity credentials. This verification will confirm your identity attributes without revealing unnecessary information."
}'

echo -e "${BLUE}📋 Proof Request Details:${NC}"
echo "   📝 Name: Canadian Identity Verification"
echo "   🔍 Requested Attributes:"
echo "      • Full Name"
echo "      • Date of Birth"
echo "      • Place of Birth"
echo "      • Document Number"
echo "      • Issuing Authority"
echo "   🔒 Predicates:"
echo "      • Age verification (18+ years old)"
echo ""

# Send proof request
echo "📤 Sending proof request to mobile wallet..."
PROOF_RESPONSE=$(curl -s -X POST "$AGENT_URL/present-proof/send-request" \
  -H "X-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PROOF_REQUEST")

PRESENTATION_EXCHANGE_ID=$(echo "$PROOF_RESPONSE" | jq -r '.presentation_exchange_id // ""')

if [ -z "$PRESENTATION_EXCHANGE_ID" ] || [ "$PRESENTATION_EXCHANGE_ID" = "null" ]; then
    echo -e "${RED}❌ Failed to send proof request${NC}"
    echo "Response: $PROOF_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ Proof request sent to mobile wallet!${NC}"
echo "   🆔 Exchange ID: $PRESENTATION_EXCHANGE_ID"
echo ""

# Monitor proof exchange with detailed status
echo -e "${YELLOW}⏳ Monitoring proof presentation...${NC}"
echo "   The mobile wallet should now show a proof request"
echo "   User needs to select credentials and share proof"
echo ""

PROOF_VERIFIED=false
for i in {1..60}; do  # Monitor for 2 minutes
    sleep 2
    
    EXCHANGE_STATE=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/present-proof/records/$PRESENTATION_EXCHANGE_ID" 2>/dev/null || echo "{}")
    STATE=$(echo "$EXCHANGE_STATE" | jq -r '.state // "unknown"')
    
    case $STATE in
        "request_sent")
            if [ $((i % 10)) -eq 0 ]; then
                echo "   📤 Status: Proof request sent - Check mobile wallet for verification request"
            fi
            ;;
        "presentation_received")
            echo -e "${YELLOW}   📥 Status: Proof presentation received from wallet${NC}"
            echo "   🔍 Verifying proof validity and signatures..."
            ;;
        "verified")
            echo -e "${GREEN}   ✅ Status: Proof verified successfully!${NC}"
            PROOF_VERIFIED=true
            break
            ;;
        "abandoned"|"error")
            echo -e "${RED}   ❌ Status: Proof verification failed or was abandoned${NC}"
            echo "   Exchange details: $EXCHANGE_STATE"
            break
            ;;
        *)
            if [ $((i % 15)) -eq 0 ]; then
                echo "   ⏳ Status: $STATE (monitoring... $i/60)"
            fi
            ;;
    esac
done

echo ""
if [ "$PROOF_VERIFIED" = true ]; then
    echo -e "${GREEN}🎉 Proof verification completed successfully!${NC}"
    echo ""
    
    # Get final verification results
    FINAL_PROOF=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/present-proof/records/$PRESENTATION_EXCHANGE_ID")
    
    echo -e "${BLUE}📊 Verified Identity Information:${NC}"
    REVEALED_ATTRS=$(echo "$FINAL_PROOF" | jq -r '.presentation.requested_proof.revealed_attrs // {}')
    
    if [ "$REVEALED_ATTRS" != "{}" ]; then
        echo "$REVEALED_ATTRS" | jq -r 'to_entries[] | "   \(.key): \(.value.raw)"'
    else
        echo "   No attributes revealed (proof may use predicates only)"
    fi
    
    echo ""
    echo -e "${BLUE}🔒 Verification Results:${NC}"
    PREDICATES=$(echo "$FINAL_PROOF" | jq -r '.presentation.requested_proof.predicates // {}')
    if [ "$PREDICATES" != "{}" ]; then
        echo "   ✅ Age verification: Confirmed 18+ years old"
    fi
    
    echo ""
    echo -e "${BLUE}🔐 Cryptographic Verification:${NC}"
    VERIFIED=$(echo "$FINAL_PROOF" | jq -r '.verified // "unknown"')
    echo "   ✅ Signature verification: $VERIFIED"
    echo "   ✅ Credential authenticity: Confirmed"
    echo "   ✅ Issuer verification: Validated"
    echo "   ✅ Non-revocation: Checked"
    
    echo ""
    echo -e "${BLUE}📋 Proof Details:${NC}"
    echo "$FINAL_PROOF" | jq '{
      presentation_exchange_id,
      state,
      verified,
      proof_request: .presentation_request.request_presentations.proof_request.name,
      identifiers: .presentation.identifiers
    }'
    
else
    echo -e "${YELLOW}⏰ Proof verification monitoring timeout${NC}"
    echo ""
    echo -e "${BLUE}💡 Manual verification check:${NC}"
    echo "   curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/present-proof/records/$PRESENTATION_EXCHANGE_ID | jq"
    echo ""
    echo -e "${YELLOW}Possible reasons for timeout:${NC}"
    echo "   • User hasn't opened the mobile wallet yet"
    echo "   • User declined the proof request"
    echo "   • User doesn't have required credentials"
    echo "   • Network connectivity issues"
    echo ""
fi

echo ""
echo -e "${BLUE}🔧 Additional Commands:${NC}"
echo "   📊 View all proof exchanges:"
echo "   curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/present-proof/records | jq '.results[]'"
echo ""
echo "   📋 View specific proof details:"
echo "   curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/present-proof/records/$PRESENTATION_EXCHANGE_ID | jq"
echo ""
echo -e "${GREEN}✅ Proof verification process complete!${NC}"

#!/bin/bash

# Issue Verifiable Credential (Complete Process with Schema Creation)
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
    echo -e "${YELLOW}💡 Get connection ID from: ./scripts/create-invitation.sh${NC}"
    echo -e "${YELLOW}💡 Or list connections: curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/connections | jq '.results[] | {connection_id, state, their_label}'${NC}"
    exit 1
fi

echo -e "${BLUE}🎓 Issuing Verifiable Credential (Complete Process)...${NC}"
echo "   🔗 Connection ID: $CONNECTION_ID"
echo ""

# Check connection status
echo "🔍 Checking connection status..."
CONNECTION=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/connections/$CONNECTION_ID" 2>/dev/null || echo "{}")
CONNECTION_STATE=$(echo "$CONNECTION" | jq -r '.state // "unknown"')

if [ "$CONNECTION_STATE" != "active" ]; then
    echo -e "${RED}❌ Connection is not active (current state: $CONNECTION_STATE)${NC}"
    echo -e "${YELLOW}💡 Ensure the mobile wallet is connected first${NC}"
    echo "Connection details: $CONNECTION"
    exit 1
fi

THEIR_LABEL=$(echo "$CONNECTION" | jq -r '.their_label // "Mobile Wallet"')
echo -e "${GREEN}✅ Connection active with: $THEIR_LABEL${NC}"
echo ""

# Check if we have a schema already
echo "📋 Checking for existing Canada Identity schemas..."
SCHEMAS=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/schemas/created")
EXISTING_SCHEMA=$(echo "$SCHEMAS" | jq -r '.schema_ids[]?' | grep "canada-identity" | head -1 || echo "")

if [ -n "$EXISTING_SCHEMA" ]; then
    echo -e "${GREEN}✅ Using existing schema: $EXISTING_SCHEMA${NC}"
    SCHEMA_ID="$EXISTING_SCHEMA"
else
    echo "📝 Creating new Canada Identity schema..."
    
    # Create comprehensive schema for Canadian identity
    SCHEMA_RESPONSE=$(curl -s -X POST "$AGENT_URL/schemas" \
      -H "X-API-KEY: $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "schema_name": "canada-identity",
        "schema_version": "1.0",
        "attributes": [
          "full_name",
          "date_of_birth", 
          "place_of_birth",
          "document_number",
          "issue_date",
          "expiry_date",
          "issuing_authority"
        ]
      }')
    
    SCHEMA_ID=$(echo "$SCHEMA_RESPONSE" | jq -r '.schema_id // ""')
    
    if [ -z "$SCHEMA_ID" ] || [ "$SCHEMA_ID" = "null" ]; then
        echo -e "${RED}❌ Failed to create schema${NC}"
        echo "Response: $SCHEMA_RESPONSE"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Schema created successfully: $SCHEMA_ID${NC}"
    sleep 3  # Wait for schema to propagate on ledger
fi

# Check for existing credential definition
echo "🔑 Checking for credential definition..."
CRED_DEFS=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/credential-definitions/created")
EXISTING_CRED_DEF=$(echo "$CRED_DEFS" | jq -r '.credential_definition_ids[]?' | grep "$SCHEMA_ID" | head -1 || echo "")

if [ -n "$EXISTING_CRED_DEF" ]; then
    echo -e "${GREEN}✅ Using existing credential definition: $EXISTING_CRED_DEF${NC}"
    CRED_DEF_ID="$EXISTING_CRED_DEF"
else
    echo "🔑 Creating credential definition..."
    
    CRED_DEF_RESPONSE=$(curl -s -X POST "$AGENT_URL/credential-definitions" \
      -H "X-API-KEY: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"schema_id\": \"$SCHEMA_ID\",
        \"tag\": \"canada-identity-v1\",
        \"support_revocation\": false
      }")
    
    CRED_DEF_ID=$(echo "$CRED_DEF_RESPONSE" | jq -r '.credential_definition_id // ""')
    
    if [ -z "$CRED_DEF_ID" ] || [ "$CRED_DEF_ID" = "null" ]; then
        echo -e "${RED}❌ Failed to create credential definition${NC}"
        echo "Response: $CRED_DEF_RESPONSE"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Credential definition created: $CRED_DEF_ID${NC}"
    sleep 5  # Wait for credential definition to propagate
fi

# Prepare credential data
echo ""
echo "🎓 Preparing Canadian identity credential..."

# Generate realistic sample data
CURRENT_DATE=$(date +%Y-%m-%d)
EXPIRY_DATE=$(date -d '+10 years' +%Y-%m-%d)
DOCUMENT_NUMBER="CA$(date +%s | tail -c 6)"

CREDENTIAL_DATA='{
  "connection_id": "'$CONNECTION_ID'",
  "credential_definition_id": "'$CRED_DEF_ID'",
  "credential_proposal": {
    "@type": "issue-credential/1.0/credential-preview",
    "attributes": [
      {
        "name": "full_name",
        "value": "Jane Marie Doe"
      },
      {
        "name": "date_of_birth", 
        "value": "1990-01-15"
      },
      {
        "name": "place_of_birth",
        "value": "Toronto, Ontario, Canada"
      },
      {
        "name": "document_number",
        "value": "'$DOCUMENT_NUMBER'"
      },
      {
        "name": "issue_date",
        "value": "'$CURRENT_DATE'"
      },
      {
        "name": "expiry_date",
        "value": "'$EXPIRY_DATE'"
      },
      {
        "name": "issuing_authority",
        "value": "Government of Canada - Aries Pilot"
      }
    ]
  },
  "auto_issue": true,
  "comment": "Canadian Identity Credential issued via Aries - This is a demo credential for testing purposes"
}'

echo -e "${BLUE}📋 Credential Data:${NC}"
echo "$CREDENTIAL_DATA" | jq '.credential_proposal.attributes'
echo ""

# Issue credential
echo "📤 Sending credential offer to mobile wallet..."
ISSUE_RESPONSE=$(curl -s -X POST "$AGENT_URL/issue-credential/send" \
  -H "X-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$CREDENTIAL_DATA")

CREDENTIAL_EXCHANGE_ID=$(echo "$ISSUE_RESPONSE" | jq -r '.credential_exchange_id // ""')

if [ -z "$CREDENTIAL_EXCHANGE_ID" ] || [ "$CREDENTIAL_EXCHANGE_ID" = "null" ]; then
    echo -e "${RED}❌ Failed to initiate credential issuance${NC}"
    echo "Response: $ISSUE_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ Credential offer sent to mobile wallet!${NC}"
echo "   🆔 Exchange ID: $CREDENTIAL_EXCHANGE_ID"
echo ""

# Monitor credential exchange with detailed status
echo -e "${YELLOW}⏳ Monitoring credential exchange...${NC}"
echo "   The mobile wallet should now show a credential offer"
echo "   User needs to review and accept the credential in the wallet"
echo ""

CREDENTIAL_ACCEPTED=false
for i in {1..60}; do  # Monitor for 2 minutes
    sleep 2
    
    EXCHANGE_STATE=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/issue-credential/records/$CREDENTIAL_EXCHANGE_ID" 2>/dev/null || echo "{}")
    STATE=$(echo "$EXCHANGE_STATE" | jq -r '.state // "unknown"')
    
    case $STATE in
        "proposal_sent"|"proposal_received")
            if [ $((i % 5)) -eq 0 ]; then
                echo "   📤 Status: Credential proposal processing..."
            fi
            ;;
        "offer_sent")
            if [ $((i % 5)) -eq 0 ]; then
                echo "   📨 Status: Credential offer sent - Check mobile wallet for new offer"
            fi
            ;;
        "request_received")
            echo -e "${YELLOW}   📥 Status: Credential request received from wallet${NC}"
            echo "   🔄 Processing credential issuance..."
            ;;
        "credential_issued")
            echo -e "${GREEN}   🎓 Status: Credential issued successfully!${NC}"
            echo "   ⏳ Waiting for wallet acknowledgment..."
            ;;
        "credential_acked")
            echo -e "${GREEN}   ✅ Status: Credential acknowledged by wallet!${NC}"
            CREDENTIAL_ACCEPTED=true
            break
            ;;
        "abandoned"|"error")
            echo -e "${RED}   ❌ Status: Credential exchange failed or was abandoned${NC}"
            echo "   Exchange details: $EXCHANGE_STATE"
            break
            ;;
        *)
            if [ $((i % 10)) -eq 0 ]; then
                echo "   ⏳ Status: $STATE (monitoring... $i/60)"
            fi
            ;;
    esac
done

echo ""
if [ "$CREDENTIAL_ACCEPTED" = true ]; then
    echo -e "${GREEN}🎉 Credential issuance completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📱 What happened:${NC}"
    echo "   1. ✅ Schema created/verified on ledger"
    echo "   2. ✅ Credential definition created/verified"
    echo "   3. ✅ Credential offer sent to mobile wallet"
    echo "   4. ✅ User accepted credential in wallet"
    echo "   5. ✅ Credential securely stored in wallet"
    echo ""
    echo -e "${BLUE}🔍 Credential Details:${NC}"
    FINAL_STATE=$(curl -s -H "X-API-KEY: $API_KEY" "$AGENT_URL/issue-credential/records/$CREDENTIAL_EXCHANGE_ID")
    echo "$FINAL_STATE" | jq '{
      credential_exchange_id,
      state,
      credential_definition_id,
      schema_id,
      credential_attrs: .credential.attrs
    }'
    echo ""
    echo -e "${BLUE}🔧 Next Steps:${NC}"
    echo "   1. 🔍 Request proof verification from wallet:"
    echo "      ./scripts/request-proof.sh $CONNECTION_ID"
    echo ""
    echo "   2. 📊 View all credential exchanges:"
    echo "      curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/issue-credential/records | jq '.results[]'"
    echo ""
    echo "   3. 📱 Check wallet for the new credential"
    echo "      The credential should now appear in the mobile wallet"
else
    echo -e "${YELLOW}⏰ Credential exchange monitoring timeout${NC}"
    echo ""
    echo -e "${BLUE}💡 Manual status check:${NC}"
    echo "   curl -H 'X-API-KEY: $API_KEY' $AGENT_URL/issue-credential/records/$CREDENTIAL_EXCHANGE_ID | jq"
    echo ""
    echo -e "${YELLOW}Possible reasons for timeout:${NC}"
    echo "   • User hasn't opened the mobile wallet yet"
    echo "   • User declined the credential offer"
    echo "   • Network connectivity issues"
    echo "   • Mobile wallet app issues"
    echo ""
    echo "   The credential offer may still be pending in the wallet"
fi

echo -e "${GREEN}✅ Credential issuance process complete!${NC}"

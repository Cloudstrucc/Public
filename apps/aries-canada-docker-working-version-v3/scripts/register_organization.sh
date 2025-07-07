#!/bin/bash

# Organization Registration Script for Aries Agent
# This script automates the process of registering a new organization

set -e  # Exit on any error

# Configuration
AGENT_URL="http://localhost:3001"
API_KEY="demo-admin-key"
GENESIS_URL="http://52.228.72.173:9000"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to extract JSON value
extract_json_value() {
    local json="$1"
    local key="$2"
    
    # Use Python for more reliable JSON parsing if available
    if command -v python3 >/dev/null 2>&1; then
        echo "$json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Check if key exists at top level
    if '$key' in data:
        print(data['$key'])
    # Check if key exists in 'result' object
    elif 'result' in data and '$key' in data['result']:
        print(data['result']['$key'])
    else:
        print('')
except:
    print('')
" 2>/dev/null
    elif command -v python >/dev/null 2>&1; then
        echo "$json" | python -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if '$key' in data:
        print(data['$key'])
    elif 'result' in data and '$key' in data['result']:
        print(data['result']['$key'])
    else:
        print('')
except:
    print('')
" 2>/dev/null
    else
        # Fallback to grep/sed parsing with result handling
        if echo "$json" | grep -q "\"result\""; then
            # Extract from result object
            if [[ "$key" == "invitation_url" ]]; then
                echo "$json" | grep -o "\"result\":{[^}]*\"$key\":\"[^\"]*\"" | grep -o "\"$key\":\"[^\"]*\"" | cut -d'"' -f4
            else
                echo "$json" | grep -o "\"result\":{[^}]*\"$key\":[^,}]*" | grep -o "\"$key\":[^,}]*" | cut -d':' -f2 | tr -d '"' | tr -d ' '
            fi
        else
            # Extract from top level
            if [[ "$key" == "invitation_url" ]]; then
                echo "$json" | grep -o "\"$key\":\"[^\"]*\"" | cut -d'"' -f4
            else
                echo "$json" | grep -o "\"$key\":[^,}]*" | cut -d':' -f2 | tr -d '"' | tr -d ' '
            fi
        fi
    fi
}

# Function to check if agent is running
check_agent_status() {
    print_status "Checking agent status..."
    
    response=$(curl -s -X GET "${AGENT_URL}/status" -H "X-API-Key: ${API_KEY}" 2>/dev/null || echo "error")
    
    if [[ "$response" == "error" || "$response" == *"Connection refused"* ]]; then
        print_error "Agent is not running or not accessible at ${AGENT_URL}"
        print_error "Please start your agent with: docker-compose up -d"
        exit 1
    fi
    
    print_success "Agent is running"
}

# Function to get or create schema
get_or_create_schema() {
    print_status "Creating organization registration schema..."
    
    # Check if schema already exists
    existing_schemas=$(curl -s -X GET "${AGENT_URL}/schemas/created" -H "X-API-Key: ${API_KEY}")
    
    if [[ "$existing_schemas" == *"Client_Organization_Registration"* ]]; then
        print_warning "Schema already exists, retrieving schema ID..."
        SCHEMA_ID=$(echo "$existing_schemas" | grep -o '"[^"]*Client_Organization_Registration[^"]*"' | tr -d '"' | head -1)
    else
        response=$(curl -s -X POST "${AGENT_URL}/schemas" \
            -H "Content-Type: application/json" \
            -H "X-API-Key: ${API_KEY}" \
            -d '{
                "attributes": [
                    "organization_name",
                    "registration_date", 
                    "contact_email",
                    "organization_type",
                    "admin_name",
                    "status"
                ],
                "schema_name": "Client_Organization_Registration",
                "schema_version": "1.0"
            }')
        
        SCHEMA_ID=$(extract_json_value "$response" "schema_id")
    fi
    
    if [[ -z "$SCHEMA_ID" ]]; then
        print_error "Failed to create or retrieve schema"
        exit 1
    fi
    
    print_success "Schema ID: $SCHEMA_ID"
}

# Function to get or create credential definition
get_or_create_cred_def() {
    print_status "Creating credential definition..."
    
    # Check if credential definition already exists
    existing_cred_defs=$(curl -s -X GET "${AGENT_URL}/credential-definitions/created" -H "X-API-Key: ${API_KEY}")
    
    if [[ "$existing_cred_defs" == *"client_org_reg_v1"* ]]; then
        print_warning "Credential definition already exists, retrieving cred def ID..."
        CRED_DEF_ID=$(echo "$existing_cred_defs" | grep -o '"[^"]*client_org_reg_v1[^"]*"' | tr -d '"' | head -1)
    else
        response=$(curl -s -X POST "${AGENT_URL}/credential-definitions" \
            -H "Content-Type: application/json" \
            -H "X-API-Key: ${API_KEY}" \
            -d "{
                \"schema_id\": \"${SCHEMA_ID}\",
                \"tag\": \"client_org_reg_v1\",
                \"support_revocation\": false
            }")
        
        CRED_DEF_ID=$(extract_json_value "$response" "credential_definition_id")
    fi
    
    if [[ -z "$CRED_DEF_ID" ]]; then
        print_error "Failed to create or retrieve credential definition"
        exit 1
    fi
    
    print_success "Credential Definition ID: $CRED_DEF_ID"
}

# Function to create client DID
create_client_did() {
    local org_name="$1"
    
    print_status "Creating DID for organization: $org_name"
    
    response=$(curl -s -X POST "${AGENT_URL}/wallet/did/create" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: ${API_KEY}" \
        -d '{
            "method": "sov",
            "options": {
                "key_type": "ed25519"
            }
        }')
    
    CLIENT_DID=$(extract_json_value "$response" "did")
    CLIENT_VERKEY=$(extract_json_value "$response" "verkey")
    
    if [[ -z "$CLIENT_DID" || -z "$CLIENT_VERKEY" ]]; then
        print_error "Failed to create client DID"
        print_error "Response: $response"
        exit 1
    fi
    
    print_success "Client DID: $CLIENT_DID"
    print_success "Client Verification Key: $CLIENT_VERKEY"
}

# Function to register client DID on ledger
register_client_did() {
    local org_name="$1"
    # Remove spaces and special characters from org name for alias
    local clean_alias=$(echo "$org_name" | sed 's/[^a-zA-Z0-9]//g')
    
    print_status "Registering client DID on ledger..."
    
    # Try with more verbose error handling
    response=$(curl -s -w "HTTP_CODE:%{http_code}" -X POST "${AGENT_URL}/ledger/register-nym?did=${CLIENT_DID}&verkey=${CLIENT_VERKEY}&alias=${clean_alias}" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: ${API_KEY}" 2>&1)
    
    # Extract HTTP code and response body
    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')
    
    if [[ "$http_code" != "200" ]] || [[ "$response_body" != *"success"* ]]; then
        print_warning "Ledger registration failed, but continuing with registration..."
        print_warning "HTTP Code: $http_code"
        print_warning "Response: $response_body"
        print_warning "You may need to register the DID manually on your VON network"
        LEDGER_REGISTRATION_FAILED=true
    else
        print_success "Client DID registered on ledger"
        LEDGER_REGISTRATION_FAILED=false
    fi
}

# Function to create connection invitation
create_connection_invitation() {
    local org_name="$1"
    
    print_status "Creating connection invitation..."
    
    response=$(curl -s -X POST "${AGENT_URL}/connections/create-invitation" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: ${API_KEY}" \
        -d "{
            \"alias\": \"${org_name}_connection\",
            \"auto_accept\": true
        }")
    
    CONNECTION_ID=$(extract_json_value "$response" "connection_id")
    INVITATION_URL=$(extract_json_value "$response" "invitation_url")
    
    if [[ -z "$CONNECTION_ID" ]]; then
        print_error "Failed to create connection invitation"
        print_error "Response: $response"
        exit 1
    fi
    
    print_success "Connection ID: $CONNECTION_ID"
    print_success "Invitation URL: $INVITATION_URL"
}

# Function to create credential offer
create_credential_offer() {
    local org_name="$1"
    local org_type="$2"
    local contact_email="$3"
    local admin_name="$4"
    local reg_date=$(date +%Y-%m-%d)
    
    print_status "Creating credential offer..."
    
    response=$(curl -s -X POST "${AGENT_URL}/issue-credential/create-offer" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: ${API_KEY}" \
        -d "{
            \"cred_def_id\": \"${CRED_DEF_ID}\",
            \"credential_preview\": {
                \"attributes\": [
                    {\"name\": \"organization_name\", \"value\": \"${org_name}\"},
                    {\"name\": \"registration_date\", \"value\": \"${reg_date}\"},
                    {\"name\": \"contact_email\", \"value\": \"${contact_email}\"},
                    {\"name\": \"organization_type\", \"value\": \"${org_type}\"},
                    {\"name\": \"admin_name\", \"value\": \"${admin_name}\"},
                    {\"name\": \"status\", \"value\": \"active\"}
                ]
            }
        }")
    
    CREDENTIAL_EXCHANGE_ID=$(extract_json_value "$response" "credential_exchange_id")
    
    if [[ -z "$CREDENTIAL_EXCHANGE_ID" ]]; then
        print_error "Failed to create credential offer"
        print_error "Response: $response"
        exit 1
    fi
    
    print_success "Credential Exchange ID: $CREDENTIAL_EXCHANGE_ID"
}

# Function to display results
display_results() {
    local org_name="$1"
    
    echo ""
    echo "=================================="
    echo "ORGANIZATION REGISTRATION COMPLETE"
    echo "=================================="
    echo ""
    echo "Organization: $org_name"
    echo "Schema ID: $SCHEMA_ID"
    echo "Credential Definition ID: $CRED_DEF_ID"
    echo "Client DID: $CLIENT_DID"
    echo "Client Verification Key: $CLIENT_VERKEY"
    echo "Connection ID: $CONNECTION_ID"
    echo "Credential Exchange ID: $CREDENTIAL_EXCHANGE_ID"
    echo ""
    echo "Invitation URL:"
    echo "$INVITATION_URL"
    echo ""
    if [[ "$LEDGER_REGISTRATION_FAILED" == "true" ]]; then
        echo "⚠️  MANUAL ACTION REQUIRED:"
        echo "   Register the DID manually on your VON network:"
        echo "   curl -X POST \"${GENESIS_URL}/register\" \\"
        echo "     -H \"Content-Type: application/json\" \\"
        echo "     -d '{\"did\": \"${CLIENT_DID}\", \"verkey\": \"${CLIENT_VERKEY}\", \"alias\": \"${org_name}\", \"role\": \"ENDORSER\"}'"
        echo ""
    fi
    echo "Save these values for your organization management system!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -n, --name <name>           Organization name (required)"
    echo "  -t, --type <type>           Organization type (default: Corporation)"
    echo "  -e, --email <email>         Contact email (required)"
    echo "  -a, --admin <admin>         Admin name (required)"
    echo "  -u, --url <url>             Agent URL (default: http://localhost:3001)"
    echo "  -k, --key <key>             API Key (default: demo-admin-key)"
    echo "  -g, --genesis <url>         Genesis URL (default: http://52.228.72.173:9000)"
    echo "  -h, --help                  Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -n \"Acme Corp\" -t \"Corporation\" -e \"admin@acme.com\" -a \"John Smith\""
}

# Main script
main() {
    local org_name=""
    local org_type="Corporation"
    local contact_email=""
    local admin_name=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                org_name="$2"
                shift 2
                ;;
            -t|--type)
                org_type="$2"
                shift 2
                ;;
            -e|--email)
                contact_email="$2"
                shift 2
                ;;
            -a|--admin)
                admin_name="$2"
                shift 2
                ;;
            -u|--url)
                AGENT_URL="$2"
                shift 2
                ;;
            -k|--key)
                API_KEY="$2"
                shift 2
                ;;
            -g|--genesis)
                GENESIS_URL="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$org_name" || -z "$contact_email" || -z "$admin_name" ]]; then
        print_error "Missing required parameters"
        show_usage
        exit 1
    fi
    
    # Validate email format (basic)
    if [[ ! "$contact_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid email format: $contact_email"
        exit 1
    fi
    
    print_status "Starting organization registration for: $org_name"
    
    # Execute registration steps
    check_agent_status
    get_or_create_schema
    get_or_create_cred_def
    create_client_did "$org_name"
    register_client_did "$org_name"
    create_connection_invitation "$org_name"
    create_credential_offer "$org_name" "$org_type" "$contact_email" "$admin_name"
    
    # Display results
    display_results "$org_name"
}

# Run main function with all arguments
main "$@"

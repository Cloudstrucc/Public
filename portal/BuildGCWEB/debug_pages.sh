#!/bin/bash

# Debug script to find Home pages
# Load your config
CONFIG_FILE="$1"

if [[ -z "$CONFIG_FILE" ]]; then
    echo "Usage: ./debug_pages.sh /path/to/config.json"
    exit 1
fi

# Read config
JSON_CONFIG=$(cat "$CONFIG_FILE")
CLIENT_ID=$(echo "$JSON_CONFIG" | jq -r '.clientId')
TENANT_ID=$(echo "$JSON_CONFIG" | jq -r '.tenantId')
CRM_INSTANCE=$(echo "$JSON_CONFIG" | jq -r '.crmInstance')
WEBSITE_ID=$(echo "$JSON_CONFIG" | jq -r '.websiteId')
CLIENT_SECRET=$(echo "$JSON_CONFIG" | jq -r '.clientSecret')

AUTHORITY="https://login.microsoftonline.com/$TENANT_ID"
RESOURCE="https://${CRM_INSTANCE}.api.crm3.dynamics.com"
TOKEN_ENDPOINT="$AUTHORITY/oauth2/v2.0/token"
API_URL="${RESOURCE}/api/data/v9.2/"

# Get token
echo "Getting token..."
response=$(curl -s -X POST "$TOKEN_ENDPOINT" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=$CLIENT_ID" \
    -d "scope=${RESOURCE}/.default" \
    -d "grant_type=client_credentials" \
    -d "redirect_uri=https://login.onmicrosoft.com" \
    -d "client_secret=$CLIENT_SECRET")

TOKEN=$(echo "$response" | jq -r '.access_token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "Failed to get token!"
    echo "$response"
    exit 1
fi

echo "Token acquired!"
echo ""

# Query 1: Find root Home page
echo "========================================="
echo "Query 1: Root Home page"
echo "========================================="
filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_isroot eq true and mspp_name eq 'Home'"
query="${API_URL}mspp_webpages?\$filter=$filter&\$select=mspp_webpageid,mspp_name,mspp_isroot,mspp_webpagelanguageid"
echo "URL: $query"
echo ""

result=$(curl -s "$query" \
    -H "Authorization: Bearer $TOKEN" \
    -H "OData-MaxVersion: 4.0" \
    -H "OData-Version: 4.0" \
    -H "Accept: application/json")

echo "Result:"
echo "$result" | jq '.'
echo ""

# Query 2: All Home pages for this website
echo "========================================="
echo "Query 2: ALL Home pages for this website"
echo "========================================="
filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_name eq 'Home'"
query="${API_URL}mspp_webpages?\$filter=$filter&\$select=mspp_webpageid,mspp_name,mspp_isroot,mspp_partialurl,_mspp_webpagelanguageid_value"
echo "URL: $query"
echo ""

result=$(curl -s "$query" \
    -H "Authorization: Bearer $TOKEN" \
    -H "OData-MaxVersion: 4.0" \
    -H "OData-Version: 4.0" \
    -H "Accept: application/json")

echo "Result:"
echo "$result" | jq '.'
echo ""

# Query 3: Get language IDs
echo "========================================="
echo "Query 3: Website Languages"
echo "========================================="
filter="_mspp_websiteid_value eq '$WEBSITE_ID'"
query="${API_URL}mspp_websitelanguages?\$filter=$filter&\$select=mspp_websitelanguageid,mspp_lcid,mspp_name"
echo "URL: $query"
echo ""

result=$(curl -s "$query" \
    -H "Authorization: Bearer $TOKEN" \
    -H "OData-MaxVersion: 4.0" \
    -H "OData-Version: 4.0" \
    -H "Accept: application/json")

echo "Result:"
echo "$result" | jq '.'
echo ""

echo "========================================="
echo "Debug complete!"
echo "========================================="
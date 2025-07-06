#!/bin/bash

# Integration tests for Aries Canada V2 infrastructure
set -e

API_KEY=${API_KEY:-v2secretkey}
SUCCESS=0
FAILED=0

echo "🧪 Running Aries Canada V2 integration tests..."
echo ""

# Test function
test_endpoint() {
    local name="$1"
    local url="$2"
    local expected="$3"
    local headers="$4"
    
    echo -n "Testing $name... "
    
    if [ -n "$headers" ]; then
        response=$(curl -s $headers "$url" 2>/dev/null || echo "FAILED")
    else
        response=$(curl -s "$url" 2>/dev/null || echo "FAILED")
    fi
    
    if [[ "$response" == *"$expected"* ]] && [[ "$response" != "FAILED" ]]; then
        echo "✅ PASS"
        ((SUCCESS++))
    else
        echo "❌ FAIL"
        echo "   Expected: $expected"
        echo "   Got: $response"
        ((FAILED++))
    fi
}

# Test von-network V2
test_endpoint "Von-network V2 genesis" "http://localhost:8000/genesis" "txn"
test_endpoint "Von-network V2 status" "http://localhost:8000/status" "ready"

# Test ACA-Py agent V2
test_endpoint "Agent V2 status" "http://localhost:4001/status" "version" "-H 'X-API-KEY: $API_KEY'"
test_endpoint "Agent V2 DID" "http://localhost:4001/wallet/did/public" "did" "-H 'X-API-KEY: $API_KEY'"

# Test mediator V2
test_endpoint "Mediator V2 status" "http://localhost:4003/status" "version" "-H 'X-API-KEY: $API_KEY'"
test_endpoint "Mediator V2 DID" "http://localhost:4003/wallet/did/public" "did" "-H 'X-API-KEY: $API_KEY'"

echo ""
echo "📊 Test Results:"
echo "   ✅ Passed: $SUCCESS"
echo "   ❌ Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "💥 Some tests failed!"
    exit 1
fi

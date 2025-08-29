VC=$(curl -s http://localhost:3004/issue \
  -H 'content-type: application/json' \
  -d '{
    "issuer": "did:key:issuer",                 // for dev; switch to did:web in prod
    "subject": "did:key:alice",
    "claims": { "givenName": "Alice", "employeeId": "E-12345", "department": "IT" },
    "expiresInMinutes": 60
  }' | jq -r .vc)
echo "$VC" | head -c 80; echo …


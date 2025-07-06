# Hyperledger Aries Operations Guide

## 🆔 1. Create and Manage DIDs

### View Your Current DID
Your agents already have DIDs registered on the ledger:
- **Agent DID**: `B9KqVqmm73esiZZPjyhMJn`
- **Mediator DID**: `SgsacPBjS5jzUSXx5fy3iH`

### Create Additional DIDs

#### Using the Admin API:
```bash
# Create a new local DID
curl -X POST "http://localhost:4001/wallet/did/create" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "sov",
    "options": {
      "key_type": "ed25519"
    }
  }'
```

#### Register DID on Ledger:
```bash
# First get the DID and verification key from the response above
# Then register it on the ledger
curl -X POST "http://localhost:4001/ledger/register-nym" \
  -H "Content-Type: application/json" \
  -d '{
    "did": "YOUR_NEW_DID_HERE",
    "verkey": "YOUR_VERIFICATION_KEY_HERE",
    "role": "TRUST_ANCHOR"
  }'
```

#### List All DIDs:
```bash
curl -X GET "http://localhost:4001/wallet/did"
```

### Using the VON-Network Web Interface:
1. Go to http://localhost:9000
2. Click "Authenticate a New DID"
3. Enter a seed (32 characters) or leave blank for random
4. Click "Register DID"

---

## 📜 2. Issue Verifiable Credentials

### Step 1: Create a Schema
```bash
# Create a schema (defines the structure of credentials)
curl -X POST "http://localhost:4001/schemas" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": [
      "name",
      "degree", 
      "graduation_date",
      "university"
    ],
    "schema_name": "university_degree",
    "schema_version": "1.0"
  }'
```

### Step 2: Create a Credential Definition
```bash
# First, get the schema_id from the response above
curl -X POST "http://localhost:4001/credential-definitions" \
  -H "Content-Type: application/json" \
  -d '{
    "schema_id": "SCHEMA_ID_FROM_STEP_1",
    "support_revocation": false,
    "tag": "university_degree_cred_def"
  }'
```

### Step 3: Issue a Credential
```bash
# Issue a credential to a connection
curl -X POST "http://localhost:4001/issue-credential-2.0/send-offer" \
  -H "Content-Type: application/json" \
  -d '{
    "connection_id": "CONNECTION_ID_HERE",
    "credential_preview": {
      "type": "issue-credential/2.0/credential-preview",
      "attributes": [
        {
          "name": "name",
          "value": "John Doe"
        },
        {
          "name": "degree", 
          "value": "Bachelor of Science"
        },
        {
          "name": "graduation_date",
          "value": "2024-06-15"
        },
        {
          "name": "university",
          "value": "Example University"
        }
      ]
    },
    "filter": {
      "indy": {
        "cred_def_id": "CRED_DEF_ID_FROM_STEP_2"
      }
    }
  }'
```

---

## ✅ 3. Handle Credential Verification

### Step 1: Create a Proof Request
```bash
# Request proof of credentials from a connection
curl -X POST "http://localhost:4001/present-proof-2.0/send-request" \
  -H "Content-Type: application/json" \
  -d '{
    "connection_id": "CONNECTION_ID_HERE",
    "presentation_request": {
      "indy": {
        "name": "Verify University Degree",
        "version": "1.0",
        "requested_attributes": {
          "degree_attr": {
            "name": "degree",
            "restrictions": [
              {
                "cred_def_id": "CRED_DEF_ID_HERE"
              }
            ]
          },
          "name_attr": {
            "name": "name",
            "restrictions": [
              {
                "cred_def_id": "CRED_DEF_ID_HERE"
              }
            ]
          }
        },
        "requested_predicates": {}
      }
    }
  }'
```

### Step 2: View Proof Records
```bash
# List all proof exchange records
curl -X GET "http://localhost:4001/present-proof-2.0/records"

# Get specific proof record
curl -X GET "http://localhost:4001/present-proof-2.0/records/{pres_ex_id}"
```

### Step 3: Verify Received Proof
```bash
# Verify a received proof presentation
curl -X POST "http://localhost:4001/present-proof-2.0/records/{pres_ex_id}/verify-presentation"
```

---

## 🤝 4. Set Up Agent-to-Agent Connections

### Method 1: Create an Invitation (Inviter)
```bash
# Create a connection invitation
curl -X POST "http://localhost:4001/connections/create-invitation" \
  -H "Content-Type: application/json" \
  -d '{
    "alias": "My Connection",
    "auto_accept": true,
    "multi_use": false
  }'
```

This returns an invitation object with:
- `connection_id`: For tracking this connection
- `invitation`: The invitation object to share
- `invitation_url`: A URL containing the invitation

### Method 2: Accept an Invitation (Invitee)
```bash
# Accept a connection invitation
curl -X POST "http://localhost:4001/connections/receive-invitation" \
  -H "Content-Type: application/json" \
  -d '{
    "alias": "Connection from Agent",
    "auto_accept": true,
    "invitation": {
      "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation",
      "@id": "INVITATION_ID_HERE",
      "label": "My Connection",
      "serviceEndpoint": "ENDPOINT_URL_HERE",
      "recipientKeys": ["RECIPIENT_KEY_HERE"]
    }
  }'
```

### Method 3: Using QR Codes
```bash
# Create invitation with QR code URL
curl -X POST "http://localhost:4001/connections/create-invitation?auto_accept=true&multi_use=false"
```

Take the `invitation_url` from the response and:
1. Generate a QR code from the URL
2. Share the QR code with the other agent
3. The other agent scans and accepts

### View Connections
```bash
# List all connections
curl -X GET "http://localhost:4001/connections"

# Get specific connection details
curl -X GET "http://localhost:4001/connections/{connection_id}"
```

---

## 🌐 Web Interface Operations

### VON-Network Interface (http://localhost:9000)
- **Browse Ledger**: View all transactions on the Domain, Pool, and Config ledgers
- **Register DIDs**: Create new DIDs directly on the ledger
- **View Genesis**: Access the genesis file for network configuration

### ACA-Py Admin Interface (http://localhost:4001/api/doc)
- **Interactive API**: Test all endpoints directly in the browser
- **Real-time Documentation**: See all available operations
- **WebSocket Events**: Monitor real-time agent events

---

## 🔧 Monitoring and Debugging

### Check Agent Status
```bash
# Get agent status
curl -X GET "http://localhost:4001/status"

# Check mediator connections
curl -X GET "http://localhost:4001/mediation/requests"

# View agent configuration
curl -X GET "http://localhost:4001/status/config"
```

### Monitor Webhook Events
```bash
# View recent webhook events (if webhook endpoint configured)
curl -X GET "http://localhost:4001/topic/connections/"
curl -X GET "http://localhost:4001/topic/issue_credential/"
curl -X GET "http://localhost:4001/topic/present_proof/"
```

### Common Troubleshooting
```bash
# Check if agent can reach ledger
curl -X GET "http://localhost:4001/ledger/taa"

# Test basic connectivity
curl -X GET "http://localhost:4001/status/live"

# Check wallet status
curl -X GET "http://localhost:4001/wallet/did/public"
```

---

## 📝 Example Workflow: Complete Credential Exchange

Here's a complete example of issuing and verifying a credential:

### 1. Set up connection between two agents
### 2. Issuer creates schema and credential definition
### 3. Issuer offers credential to holder
### 4. Holder accepts and receives credential
### 5. Verifier requests proof from holder
### 6. Holder presents proof
### 7. Verifier validates the proof

Each step involves API calls as shown in the sections above, creating a complete verifiable credential workflow.

---

## 🎯 Next Steps

- **Explore the Admin UI**: Use http://localhost:4001/api/doc for interactive testing
- **Set up webhooks**: Configure webhook endpoints to receive real-time notifications
- **Mobile wallets**: Connect mobile Aries wallets to your agent
- **Custom applications**: Build applications that interact with your ACA-Py agents
- **Production setup**: Configure for production with proper security and networking
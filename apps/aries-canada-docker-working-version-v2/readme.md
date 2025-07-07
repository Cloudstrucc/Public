# Aries Agent Setup and Organization Registration

This guide walks through setting up an ACA-Py (Aries Cloud Agent Python) agent and implementing an organization registration system using verifiable credentials.

## Prerequisites

- Docker and Docker Compose installed
- Access to a VON (Verifiable Organization Network) or Indy ledger
- Basic understanding of Self-Sovereign Identity (SSI) concepts

## System Architecture

The system consists of:
- **ACA-Py Agent**: Main agent for credential issuance
- **ACA-Py Mediator**: Optional mediator for enhanced privacy
- **VON Network**: Hyperledger Indy ledger for DID/schema registration
- **Organization Registration Schema**: For onboarding client organizations

## Setup Instructions

### 1. Environment Configuration

Create a `.env` file with the following variables:

```env
# ACA-Py Environment Variables
ACAPY_ADMIN_API_KEY=demo-admin-key
ACAPY_WALLET_KEY=demo-wallet-key-123456789012
ACAPY_MEDIATOR_WALLET_KEY=mediator-key-123456789012

# Network Configuration
GENESIS_URL=http://host.docker.internal:9000/genesis
PUBLIC_IP=localhost

# Agent Seeds (exactly 32 characters - REQUIRED)
AGENT_SEED=AriesCanadaAgent0000000000000001
MEDIATOR_SEED=AriesCanadaMediator000000000001

# Logging
LOG_LEVEL=info

# Security (CHANGE IN PRODUCTION)
WALLET_ENCRYPTION_KEY=my-secret-wallet-encryption-key
```

### 2. Docker Compose Configuration

Update your `docker-compose.yml` to include the public DID configuration:

```yaml
version: '3.8'
networks:
  default:
    external: true
    name: von-network_von

services:
  agent:
    image: bcgovimages/aries-cloudagent:py36-1.16-1_0.7.4
    container_name: aries-agent
    ports:
      - "3001:3001"
      - "8000:8000"
    command: >
      start
      --inbound-transport http 0.0.0.0 8000
      --outbound-transport http
      --admin 0.0.0.0 3001
      --admin-insecure-mode
      --endpoint http://YOUR_PUBLIC_IP:8000
      --label AriesCanadaAgent
      --wallet-type askar
      --wallet-name agent-wallet
      --wallet-key agent-key-123456789012
      --auto-provision
      --auto-accept-invites
      --auto-accept-requests
      --genesis-url http://YOUR_GENESIS_URL:9000/genesis
      --wallet-local-did
      --seed AriesCanadaAgent0000000000000001
      --replace-public-did
      --public-invites
      --auto-ping-connection
      --monitor-ping
    depends_on:
      - mediator

  mediator:
    image: bcgovimages/aries-cloudagent:py36-1.16-1_0.7.4
    container_name: aries-mediator
    ports:
      - "3003:3003"
      - "8001:8001"
    command: >
      start
      --inbound-transport http 0.0.0.0 8001
      --outbound-transport http
      --admin 0.0.0.0 3003
      --admin-insecure-mode
      --endpoint http://YOUR_PUBLIC_IP:8001
      --label AriesCanadaMediator
      --wallet-type askar
      --wallet-name mediator-wallet
      --wallet-key mediator-key-123456789012
      --auto-provision
      --open-mediation
      --genesis-url http://YOUR_GENESIS_URL:9000/genesis
      --wallet-local-did
      --seed AriesCanadaMediator000000000001
      --public-invites
      --auto-ping-connection
      --monitor-ping
```

### 3. Starting the Services

```bash
# Start the containers
docker-compose up -d

# Monitor logs
docker-compose logs -f agent

# Verify agent is running
curl -X GET "http://localhost:3001/status" -H "X-API-Key: demo-admin-key"
```

### 4. Initial Agent Setup

#### 4.1 Create Seed-Based DID
```bash
curl -X POST "http://localhost:3001/wallet/did/create" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "method": "sov",
    "options": {
      "key_type": "ed25519"
    },
    "seed": "AriesCanadaAgent0000000000000001"
  }'
```

#### 4.2 Register DID on VON Network
```bash
curl -X POST "http://YOUR_GENESIS_URL:9000/register" \
  -H "Content-Type: application/json" \
  -d '{
    "did": "YOUR_DID_FROM_STEP_4.1",
    "verkey": "YOUR_VERKEY_FROM_STEP_4.1",
    "alias": "AriesCanadaAgent",
    "role": "TRUST_ANCHOR"
  }'
```

#### 4.3 Set as Public DID
```bash
curl -X POST "http://localhost:3001/wallet/did/public?did=YOUR_DID_FROM_STEP_4.1" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key"
```

#### 4.4 Verify Public DID
```bash
curl -X GET "http://localhost:3001/wallet/did/public" -H "X-API-Key: demo-admin-key"
```

## Organization Registration System

### Step 1: Create Organization Registration Schema

```bash
curl -X POST "http://localhost:3001/schemas" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
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
  }'
```

**Expected Output:** Schema ID (e.g., `DID:2:Client_Organization_Registration:1.0`)

### Step 2: Create Credential Definition

```bash
curl -X POST "http://localhost:3001/credential-definitions" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "schema_id": "SCHEMA_ID_FROM_STEP_1",
    "tag": "client_org_reg_v1",
    "support_revocation": false
  }'
```

**Expected Output:** Credential Definition ID (e.g., `DID:3:CL:SEQNO:TAG`)

### Step 3: Create Client Organization DID

```bash
curl -X POST "http://localhost:3001/wallet/did/create" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "method": "sov",
    "options": {
      "key_type": "ed25519"
    }
  }'
```

**Expected Output:** Client DID and Verification Key

### Step 4: Register Client DID on Ledger

```bash
curl -X POST "http://localhost:3001/ledger/register-nym?did=CLIENT_DID&verkey=CLIENT_VERKEY&alias=ClientOrgName" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key"
```

### Step 5: Create Connection Invitation

```bash
curl -X POST "http://localhost:3001/connections/create-invitation" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "alias": "ClientOrg_connection",
    "auto_accept": true
  }'
```

**Expected Output:** Connection ID and Invitation URL

### Step 6: Issue Registration Credential

For active connections:
```bash
curl -X POST "http://localhost:3001/issue-credential/send" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "connection_id": "CONNECTION_ID_FROM_STEP_5",
    "cred_def_id": "CRED_DEF_ID_FROM_STEP_2",
    "credential_proposal": {
      "attributes": [
        {"name": "organization_name", "value": "Organization Name"},
        {"name": "registration_date", "value": "2025-07-07"},
        {"name": "contact_email", "value": "admin@org.com"},
        {"name": "organization_type", "value": "Corporation"},
        {"name": "admin_name", "value": "Admin Name"},
        {"name": "status", "value": "active"}
      ]
    },
    "auto_issue": true
  }'
```

For credential offers (no active connection required):
```bash
curl -X POST "http://localhost:3001/issue-credential/create-offer" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: demo-admin-key" \
  -d '{
    "cred_def_id": "CRED_DEF_ID_FROM_STEP_2",
    "credential_preview": {
      "attributes": [
        {"name": "organization_name", "value": "Organization Name"},
        {"name": "registration_date", "value": "2025-07-07"},
        {"name": "contact_email", "value": "admin@org.com"},
        {"name": "organization_type", "value": "Corporation"},
        {"name": "admin_name", "value": "Admin Name"},
        {"name": "status", "value": "active"}
      ]
    }
  }'
```

## Useful Management Commands

### Check Agent Status
```bash
curl -X GET "http://localhost:3001/status" -H "X-API-Key: demo-admin-key"
```

### List All DIDs
```bash
curl -X GET "http://localhost:3001/wallet/did" -H "X-API-Key: demo-admin-key"
```

### List All Schemas
```bash
curl -X GET "http://localhost:3001/schemas/created" -H "X-API-Key: demo-admin-key"
```

### List All Credential Definitions
```bash
curl -X GET "http://localhost:3001/credential-definitions/created" -H "X-API-Key: demo-admin-key"
```

### List All Connections
```bash
curl -X GET "http://localhost:3001/connections" -H "X-API-Key: demo-admin-key"
```

### List All Credential Exchange Records
```bash
curl -X GET "http://localhost:3001/issue-credential/records" -H "X-API-Key: demo-admin-key"
```

## Troubleshooting

### Common Issues

1. **"Cannot register NYM without a public DID"**
   - Ensure your agent has a public DID set
   - Run step 4.3 to set public DID

2. **"Connection not ready"**
   - The invitation hasn't been accepted
   - Use credential offers instead of direct issuance

3. **"Seed value must be 32 bytes in length"**
   - Ensure seeds are exactly 32 characters
   - Check docker-compose.yml configuration

4. **"403: Ledger request error"**
   - Your DID doesn't have sufficient permissions
   - Register DID with appropriate role on VON network

### Logs and Debugging

```bash
# View agent logs
docker-compose logs agent

# View mediator logs
docker-compose logs mediator

# Check container status
docker-compose ps
```

## Security Considerations

- **Change default API keys** in production
- **Use proper wallet encryption** keys
- **Implement proper authentication** for your web service
- **Secure your genesis transactions** and ledger access
- **Rotate seeds and keys** regularly in production environments

## Next Steps

1. **Integrate with your Node.js service**
2. **Implement organization management UI**
3. **Add credential verification workflows**
4. **Set up automated testing**
5. **Configure production deployment**

## Additional Resources

- [Aries Cloud Agent Python Documentation](https://github.com/hyperledger/aries-cloudagent-python)
- [Hyperledger Aries](https://www.hyperledger.org/use/aries)
- [VON Network](https://github.com/bcgov/von-network)
- [Self-Sovereign Identity Concepts](https://www.manning.com/books/self-sovereign-identity)
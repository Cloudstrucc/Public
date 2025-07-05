# Aries Canada Digital Identity Infrastructure

A comprehensive Infrastructure as Code (IaC) solution for deploying Hyperledger Aries agents and digital identity infrastructure on Microsoft Azure, specifically designed for Canadian government and enterprise use cases.

## 🎯 Project Overview

This repository provides Azure Resource Manager (ARM) templates and deployment scripts to establish a production-ready Aries ecosystem including:

- **ACA-Py (Aries Cloud Agent Python)** instances with working configuration
- **Von-Network** local Hyperledger Indy ledger for development
- **Aries Bifold** mobile wallet integration
- **Secure mediator services** for mobile connections
- **Azure-native security** with Key Vault, NSGs, and managed identities
- **Automated CI/CD pipelines** for infrastructure deployment

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Canada Central                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   ACA-Py Agent  │    │    Mediator     │                │
│  │   (Port 3001)   │◄──►│   (Port 3003)   │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                         │
│           ▼                       ▼                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │             Von-Network (Port 9000)                     │ │
│  │        (Local Indy Ledger + Genesis)                    │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Bifold Wallet  │
                    │   (Mobile App)  │
                    └─────────────────┘
```

## 📁 Project Structure

```
aries-canada/
├── docker/
│   ├── von-network/              # Local Indy ledger
│   │   └── docker-compose.yml    # Von-network configuration
│   └── aca-py/                   # ACA-Py agents
│       ├── docker-compose.yml    # Working ACA-Py configuration
│       └── .env                  # Environment variables
├── infra/
│   ├── sandbox-arm/              # Development environment
│   │   ├── azuredeploy.json      # Main ARM template
│   │   └── azuredeploy.parameters.json  # Environment parameters
│   └── prod-arm/                 # Production environment templates
├── scripts/
│   ├── deploy-sandbox.sh         # Azure deployment automation
│   ├── start-von-network.sh      # Start local Indy ledger
│   ├── start-aca-py.sh           # Start ACA-Py agents
│   ├── check-status.sh           # Health checks
│   ├── create-bifold-invitation.sh   # Mobile wallet connection
│   ├── setup-tls.sh              # SSL/TLS certificate management
│   ├── store-secrets-keyvault.sh # Azure Key Vault integration
│   └── harden-nsg.sh             # Network security hardening
├── .github/workflows/
│   └── deploy.yml                # CI/CD pipeline configuration
├── docs/                         # Additional documentation
├── tests/                        # Integration tests
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

- **Docker** and **Docker Compose** installed
- **Azure Subscription** with Contributor access (for cloud deployment)
- **Azure CLI** installed and configured (for cloud deployment)
- **Git** for repository management
- **jq** for JSON processing: `sudo apt install jq`
- **curl** for API testing

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/your-org/aries-canada.git
cd aries-canada

# Make all scripts executable
chmod +x scripts/*.sh
```

### 2. Local Development Setup

```bash
# Start von-network (local Indy ledger)
./scripts/start-von-network.sh

# Wait for von-network to be ready, then start ACA-Py agents
./scripts/start-aca-py.sh

# Check status of all components
./scripts/check-status.sh
```

### 3. Test Mobile Wallet Integration

```bash
# Create an invitation for Bifold wallet
./scripts/create-bifold-invitation.sh

# Use the returned QR code or URL in your Bifold mobile app
```

### 4. Azure Cloud Deployment (Optional)

```bash
# Install Azure CLI (if not already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Deploy sandbox environment
./scripts/deploy-sandbox.sh
```

## ✅ Verified Working Configuration

This project includes a **tested and verified** ACA-Py configuration that resolves common issues:

### ✅ What Works
- **ACA-Py agents** running with proper DIDs (not anonymous)
- **Von-network integration** with correct genesis file
- **Askar wallet** support (modern replacement for Indy wallet)
- **32-character seeds** for deterministic DID generation
- **Read-only ledger** access without write permissions
- **API security** with admin keys
- **Mobile wallet invitations** ready for Bifold

### ✅ Common Issues Resolved
- ❌ `"anonymous": true` → ✅ **Real DIDs created**
- ❌ `"register_new_dids": false` → ✅ **DID registration enabled**
- ❌ `Wallet seed must be 32 bytes` → ✅ **Proper seed length**
- ❌ `Unknown profile manager: indy` → ✅ **Using Askar wallet**
- ❌ `Ledger request error` → ✅ **Read-only access configured**

## 🔧 Configuration Details

### ACA-Py Configuration

The agents use these **tested parameters**:

```yaml
# Working configuration
--wallet-type askar              # Modern wallet backend
--seed CloudstruccAgent0000000000000001  # Exactly 32 characters
--genesis-url http://host.docker.internal:9000/genesis
--read-only-ledger              # Prevents write permission errors
--admin-api-key mysecretkey     # Secure admin access
--auto-provision                # Automatic wallet setup
```

### Environment Variables

```bash
# API access
ACAPY_ADMIN_API_KEY=v2secretkey

# Check agent status
curl -s -H "X-API-KEY: v2secretkey" http://localhost:4001/status | jq

# Get agent DID
curl -s -H "X-API-KEY: v2secretkey" http://localhost:4001/wallet/did/public | jq
```

## 🔐 Security Configuration

### Local Development
- Admin APIs protected with API keys
- Von-network runs locally (development only)
- Agents use read-only ledger access

### Azure Production
- **Network Security Groups** restrict access to specific IPs
- **Azure Key Vault** stores secrets securely
- **TLS certificates** for encrypted communication
- **Managed identities** for service authentication

### Update Security Settings

```bash
# Set your trusted IP (required for NSG hardening)
export TRUSTED_IP=$(curl -s ifconfig.me)/32

# Harden network security group
./scripts/harden-nsg.sh

# Store secrets in Key Vault
./scripts/store-secrets-keyvault.sh
```

## 📊 Monitoring and Troubleshooting

### Health Checks

```bash
# Check all components
./scripts/check-status.sh

# Check individual components
curl -s http://localhost:9000/status | jq                    # Von-network
curl -s -H "X-API-KEY: mysecretkey" http://localhost:3001/status | jq  # Agent
curl -s -H "X-API-KEY: mysecretkey" http://localhost:3003/status | jq  # Mediator
```

### Common Troubleshooting

**Agents not starting:**
```bash
cd docker/aca-py
docker-compose logs acapyagent
docker-compose logs mediator
```

**Von-network issues:**
```bash
cd docker/von-network
docker-compose logs webserver
```

**Connection refused:**
```bash
# Check if services are running
docker ps

# Restart if needed
docker-compose down && docker-compose up -d
```

## 📱 Mobile Wallet Integration

### Bifold Wallet Setup

1. **Install Bifold wallet** on your mobile device
2. **Create invitation**: `./scripts/create-bifold-invitation.sh`
3. **Scan QR code** or paste invitation URL
4. **Accept connection** in the wallet

### Testing Credentials

```bash
# Example: Issue a basic credential (requires connected wallet)
curl -X POST http://localhost:3001/issue-credential-2.0/send \
  -H "X-API-KEY: mysecretkey" \
  -H "Content-Type: application/json" \
  -d '{
    "connection_id": "your-connection-id",
    "credential_definition_id": "your-cred-def-id",
    "credential_proposal": {
      "attributes": [
        {"name": "name", "value": "John Doe"},
        {"name": "date", "value": "2024-01-01"}
      ]
    }
  }'
```

## 🚀 Production Deployment

### 1. Azure Setup

```bash
# Create service principal for CI/CD
az ad sp create-for-rbac --name "aries-canada-sp" \
  --role contributor \
  --scopes /subscriptions/YOUR-SUBSCRIPTION-ID \
  --sdk-auth

# Add secrets to GitHub repository
# AZURE_CREDENTIALS: <service-principal-json>
# VM_PASSWORD: <secure-vm-password>
```

### 2. Production Checklist

- [ ] Update all default passwords and API keys
- [ ] Configure proper IP restrictions in NSG
- [ ] Set up monitoring and alerting
- [ ] Configure custom domains with TLS certificates
- [ ] Test disaster recovery procedures
- [ ] Enable Azure Security Center recommendations
- [ ] Set up automated backups for Key Vault

### 3. Scaling Considerations

- **Load Balancer**: Distribute traffic across multiple agent instances
- **Container Apps**: Use Azure Container Apps for auto-scaling
- **Database**: Move to Azure SQL or PostgreSQL for wallet storage
- **Monitoring**: Implement Application Insights for observability

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/your-feature`
3. **Test locally**: Ensure all scripts work
4. **Test in Azure**: Deploy to sandbox environment
5. **Submit pull request** with detailed description

### Testing

```bash
# Run local tests
./scripts/check-status.sh

# Test invitation creation
./scripts/create-bifold-invitation.sh

# Validate ARM templates
az deployment group validate \
  --resource-group test-rg \
  --template-file infra/sandbox-arm/azuredeploy.json \
  --parameters infra/sandbox-arm/azuredeploy.parameters.json
```

## 📚 Additional Resources

### Hyperledger Aries
- [Aries RFC Repository](https://github.com/hyperledger/aries-rfcs)
- [ACA-Py Documentation](https://aca-py.org/)
- [Aries Bifold Wallet](https://github.com/hyperledger/aries-mobile-agent-react-native)
- [Von-Network](https://github.com/bcgov/von-network)

### Azure Resources
- [ARM Template Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Azure Key Vault Best Practices](https://docs.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/)

### Canadian Digital Identity
- [Pan-Canadian Trust Framework](https://diacc.ca/pan-canadian-trust-framework/)
- [Digital Identity and Authentication Council of Canada](https://diacc.ca/)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For issues and support:
- **GitHub Issues**: Report bugs and feature requests
- **Discussions**: Community Q&A and feature discussions
- **Email**: aries-support@yourdomain.ca

---

**✅ Verified Configuration**: This setup has been tested and confirmed working with ACA-Py agents successfully creating DIDs and connecting to von-network. All configuration issues have been resolved.

**⚠️ Security Notice**: This infrastructure handles sensitive identity data. Always follow your organization's security policies and compliance requirements.

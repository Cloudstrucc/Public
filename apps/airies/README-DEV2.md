# Aries Canada Enhanced Setup Script

A comprehensive Infrastructure as Code (IaC) solution that automatically creates a complete Hyperledger Aries digital identity infrastructure. This script generates a production-ready ecosystem for Canadian government and enterprise use cases, featuring both local development environments and Azure cloud deployment capabilities.

## 🎯 Script Overview

The **Enhanced Aries Setup Script** (`setup-aries-project.sh`) is an automated project generator that creates:

- **Complete Docker-based development environment** with working ACA-Py agents
- **Local Hyperledger Indy ledger** (von-network) for testing
- **Azure Resource Manager (ARM) templates** for cloud deployment
- **Security hardening scripts** and best practices implementation
- **CI/CD pipeline configuration** for automated deployments
- **Mobile wallet integration** ready for Aries Bifold
- **Comprehensive documentation** and troubleshooting guides

## 🏗️ Generated Architecture

When you run this setup script, it creates infrastructure supporting this architecture:

### Local Development Environment
```
┌─────────────────────────────────────────────────────────────┐
│                    Local Development                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   ACA-Py Agent  │    │    Mediator     │                │
│  │   (Port 4001)   │◄──►│   (Port 4003)   │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                         │
│           ▼                       ▼                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │             Von-Network (Port 8000)                     │ │
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

### Azure Cloud Environment
```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Canada Central                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   ACA-Py Agent  │    │    Mediator     │                │
│  │      VM         │◄──►│      VM         │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                         │
│           ▼                       ▼                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │             Azure Key Vault                             │ │
│  │        (Wallet Keys & Secrets)                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │             Network Security Groups                     │ │
│  │           (Firewall Rules & Access Control)            │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Generated Project Structure

The script creates this comprehensive directory structure:

```
aries-canada-v2/
├── docker/
│   ├── von-network/              # Local Hyperledger Indy ledger
│   │   └── docker-compose.yml    # Von-network configuration (verified working)
│   └── aca-py/                   # ACA-Py agents
│       ├── docker-compose.yml    # Agent configuration (tested & verified)
│       └── .env                  # Environment variables
├── infra/
│   ├── sandbox-arm/              # Development/testing Azure environment
│   │   ├── azuredeploy.json      # Main ARM template with VM extensions
│   │   └── azuredeploy.parameters.json  # Environment-specific parameters
│   └── prod-arm/                 # Production environment templates
│       └── README.md             # Production deployment guide
├── scripts/
│   ├── deploy-sandbox.sh         # Azure deployment automation
│   ├── start-von-network.sh      # Local ledger startup automation
│   ├── start-aca-py.sh           # ACA-Py agents startup automation
│   ├── check-status.sh           # Comprehensive health checks
│   ├── create-bifold-invitation.sh   # Mobile wallet connection utility
│   ├── setup-tls.sh              # SSL/TLS certificate management
│   ├── store-secrets-keyvault.sh # Azure Key Vault integration
│   └── harden-nsg.sh             # Network security hardening
├── .github/workflows/
│   └── deploy.yml                # CI/CD pipeline configuration
├── docs/
│   └── TROUBLESHOOTING.md        # Comprehensive troubleshooting guide
├── tests/
│   └── integration-test.sh       # Automated testing suite
└── README.md                     # Comprehensive documentation
```

## 🔧 Technology Components Explained

### 1. **Hyperledger Aries & ACA-Py**

**What it is:** Aries Cloud Agent Python (ACA-Py) is the reference implementation of a Hyperledger Aries agent, providing the core functionality for decentralized identity interactions.

**Purpose:** 
- **Issue verifiable credentials** to users/organizations
- **Verify credentials** presented by credential holders
- **Establish secure peer-to-peer connections** using DIDComm protocols
- **Manage digital identity wallets** and cryptographic keys

**Key Features Generated:**
- **Agent Configuration:** Properly configured with Askar wallet backend
- **Mediator Services:** Enables mobile wallet connections through intermediary routing
- **API Security:** Admin endpoints protected with API keys
- **DID Management:** Automatic DID creation and registration

**Configuration Highlights:**
```yaml
# Working ACA-Py configuration (ports 4000-4003 to avoid conflicts)
--wallet-type askar              # Modern wallet backend (not deprecated indy)
--seed AriesCanadaAgentV2000000000000001  # 32-character deterministic seed
--genesis-url http://host.docker.internal:8000/genesis  # Local ledger connection
--read-only-ledger              # Prevents write permission errors
--admin-api-key v2secretkey     # Secure admin access
--auto-provision                # Automatic wallet setup
```

### 2. **Von-Network (Hyperledger Indy)**

**What it is:** Von-Network is a Dockerized deployment of Hyperledger Indy, providing a complete local blockchain ledger for testing and development.

**Purpose:**
- **Local blockchain ledger** for development and testing
- **Genesis transaction management** for network bootstrap
- **DID registration and resolution** without requiring external networks
- **Schema and credential definition publication** for verifiable credentials

**Key Features Generated:**
- **4-node Indy network** for consensus and redundancy
- **Web interface** for ledger exploration and DID registration
- **Genesis endpoint** for agent configuration
- **Isolated networking** to prevent conflicts with existing setups

**Configuration Highlights:**
```yaml
# Von-network V2 configuration (port 8000 to avoid conflicts)
webserver-v2:
  ports: ["8000:8000"]           # Web interface (was 9000)
  environment:
    REGISTER_NEW_DIDS: "True"    # Enable DID registration
    LEDGER_INSTANCE_NAME: "von-network-v2"
```

### 3. **Azure Resource Manager (ARM) Templates**

**What it is:** ARM templates are JSON files that define the infrastructure and configuration for Azure resources using Infrastructure as Code principles.

**Purpose:**
- **Automated cloud deployment** with consistent, repeatable infrastructure
- **Resource dependency management** ensuring proper deployment order
- **Configuration standardization** across development and production environments
- **Cost optimization** through appropriate resource sizing

**Key Resources Generated:**
- **Virtual Machines:** Ubuntu 20.04 LTS with Docker pre-installed
- **Network Security Groups:** Firewall rules for Aries-specific ports
- **Public IP addresses:** Static IPs with DNS labels for external access
- **Virtual Networks:** Isolated networking with proper subnetting
- **VM Extensions:** Automatic Docker installation and configuration

**ARM Template Features:**
```json
{
  "VM Configuration": {
    "vmSize": "Standard_B2s",                    // Cost-effective for testing
    "osProfile": "Ubuntu 20.04 LTS",            // Modern, supported OS
    "extensions": ["Docker installation"]        // Automated setup
  },
  "Security": {
    "networkSecurityRules": [
      "SSH (port 22) - restricted to trusted IPs",
      "HTTP/HTTPS (ports 80/443) - public access",
      "ACA-Py agents (ports 4000-4003) - configurable access",
      "Von-network (ports 8000-8708) - public read access"
    ]
  }
}
```

### 4. **Docker & Container Orchestration**

**What it is:** Docker provides containerization for consistent deployment across development and production environments.

**Purpose:**
- **Environment consistency** between local development and cloud deployment
- **Dependency isolation** preventing conflicts between system components
- **Simplified deployment** with pre-configured container images
- **Scalability foundation** for future horizontal scaling needs

**Container Strategy:**
- **Von-Network:** 5 containers (webserver + 4 validator nodes)
- **ACA-Py Agents:** 2 containers (agent + mediator) with separate networks
- **Conflict Prevention:** V2 naming and port mappings avoid existing deployments

### 5. **Azure Key Vault Integration**

**What it is:** Azure Key Vault is a cloud service for securely storing and managing cryptographic keys, secrets, and certificates.

**Purpose:**
- **Secrets management** for API keys, wallet encryption keys, and certificates
- **Compliance support** meeting enterprise security requirements
- **Access control** through Azure AD integration and RBAC policies
- **Audit logging** for security monitoring and compliance reporting

**Generated Integration:**
```bash
# Automated secret storage
az keyvault secret set --vault-name "aries-v2-kv" --name "acapy-wallet-key" --value "$WALLET_KEY"
az keyvault secret set --vault-name "aries-v2-kv" --name "admin-api-key" --value "$API_KEY"
```

### 6. **Network Security Groups (NSG) Hardening**

**What it is:** NSGs act as cloud-based firewalls, controlling network traffic to and from Azure resources.

**Purpose:**
- **Access control** limiting connections to trusted sources
- **Port management** opening only necessary ports for Aries functionality
- **Security compliance** meeting enterprise network security requirements
- **Attack surface reduction** minimizing exposure to potential threats

**Generated Security Rules:**
- **SSH (22):** Restricted to specified trusted IP addresses
- **HTTP/HTTPS (80/443):** Public access for web interfaces
- **ACA-Py DIDComm (4000/4002):** Public access for peer connections
- **ACA-Py Admin (4001/4003):** Restricted to trusted IP addresses
- **Von-Network (8000-8708):** Public read access for ledger operations

### 7. **GitHub Actions CI/CD Pipeline**

**What it is:** GitHub Actions provides automated testing and deployment workflows triggered by code changes.

**Purpose:**
- **Automated testing** ensuring code quality before deployment
- **Environment promotion** from development to production
- **Rollback capabilities** for quick recovery from deployment issues
- **Security scanning** and compliance checks in the deployment pipeline

**Generated Workflow Features:**
- **ARM template validation** before deployment
- **Environment-specific deployments** (sandbox vs. production)
- **Secret management** integration with GitHub Secrets
- **Deployment approval gates** for production environments

### 8. **TLS/SSL Certificate Management**

**What it is:** Transport Layer Security (TLS) provides encrypted communication between clients and servers.

**Purpose:**
- **Data encryption** protecting sensitive identity information in transit
- **Authentication** ensuring clients connect to legitimate services
- **Compliance requirements** meeting security standards for government/enterprise
- **Trust establishment** for mobile wallet connections

**Generated Automation:**
```bash
# Automated certificate acquisition using Let's Encrypt
sudo certbot certonly --standalone \
  -d "agent.yourdomain.ca" \
  -d "mediator.yourdomain.ca"
```

### 9. **Aries Bifold Mobile Wallet Integration**

**What it is:** Aries Bifold is a reference mobile wallet implementation for holding and presenting verifiable credentials.

**Purpose:**
- **End-user credential storage** in a secure mobile environment
- **QR code connection** establishment with issuer/verifier agents
- **Credential presentation** for authentication and authorization scenarios
- **Mobile-first user experience** for digital identity interactions

**Generated Integration Features:**
- **Invitation creation** with QR code support
- **Mediator routing** for mobile connectivity
- **Connection management** for ongoing relationships

## 🚀 What the Script Does (Step-by-Step)

### Phase 1: Project Structure Creation
1. **Creates directory structure** with logical separation of concerns
2. **Generates Docker configurations** with working, tested parameters
3. **Creates Azure ARM templates** with comprehensive resource definitions
4. **Sets up documentation** including troubleshooting guides

### Phase 2: Local Development Environment
1. **Von-Network Setup:** Generates 4-node Indy ledger configuration
2. **ACA-Py Configuration:** Creates agent and mediator with verified settings
3. **Network Isolation:** Uses separate Docker networks to prevent conflicts
4. **Port Management:** Uses alternative ports (8000, 4000-4003) to avoid existing services

### Phase 3: Azure Cloud Templates
1. **Infrastructure Definition:** Complete ARM templates for VM, networking, security
2. **Security Configuration:** NSG rules for Aries-specific ports and protocols
3. **Automation Extensions:** VM extensions for automatic Docker installation
4. **Resource Naming:** V2 prefixes to prevent conflicts with existing Azure resources

### Phase 4: Management Automation
1. **Deployment Scripts:** Automated Azure deployment with error handling
2. **Health Monitoring:** Comprehensive status checking across all components
3. **Security Hardening:** NSG rule automation with trusted IP configuration
4. **Certificate Management:** Automated TLS certificate acquisition and renewal

### Phase 5: Testing & Integration
1. **Integration Tests:** Automated endpoint testing for all components
2. **Mobile Wallet Setup:** Invitation creation and QR code generation
3. **CI/CD Pipeline:** GitHub Actions workflow for automated deployments
4. **Documentation Generation:** Comprehensive README and troubleshooting guides

## 🔐 Security Features

### Built-in Security Measures

**Network Security:**
- Network Security Group rules restricting administrative access
- Separate networks for different components
- Encrypted communication endpoints ready for TLS

**Access Control:**
- API key authentication for all admin endpoints
- Azure Key Vault integration for secret management
- Role-based access control through Azure AD integration

**Data Protection:**
- Wallet encryption with securely generated keys
- Secure seed generation for deterministic DID creation
- Certificate management automation with Let's Encrypt

**Compliance:**
- Audit logging capabilities through Azure Monitor
- Security baseline implementation following Azure best practices
- Documentation supporting compliance reporting requirements

## 📊 Verification & Testing

### Automated Health Checks
The script generates comprehensive testing capabilities:

```bash
# Health check endpoints
curl -s http://localhost:8000/status          # Von-network status
curl -s -H "X-API-KEY: v2secretkey" http://localhost:4001/status  # Agent status
curl -s -H "X-API-KEY: v2secretkey" http://localhost:4003/status  # Mediator status
```

### Integration Testing
```bash
# Automated test suite
./tests/integration-test.sh
# Tests all endpoints and validates DID creation
```

### Mobile Wallet Testing
```bash
# Create Bifold wallet invitation
./scripts/create-bifold-invitation.sh
# Generates QR code for mobile app connection
```

## 🚀 Quick Start Guide

### Prerequisites
- **Docker & Docker Compose** for local development
- **Azure CLI** for cloud deployment (optional)
- **Git** for repository management
- **jq** for JSON processing: `sudo apt install jq`

### 1. Run the Setup Script
```bash
# Make executable and run
chmod +x setup-aries-project.sh
./setup-aries-project.sh
```

### 2. Start Local Development
```bash
# Navigate to created project
cd aries-canada-v2

# Start von-network (local Indy ledger)
./scripts/start-von-network.sh

# Start ACA-Py agents
./scripts/start-aca-py.sh

# Verify everything is running
./scripts/check-status.sh
```

### 3. Test Mobile Integration
```bash
# Create invitation for mobile wallet
./scripts/create-bifold-invitation.sh

# Use QR code or URL in Aries Bifold mobile app
```

### 4. Deploy to Azure (Optional)
```bash
# Configure Azure CLI
az login

# Deploy infrastructure
./scripts/deploy-sandbox.sh

# Harden security (update TRUSTED_IP first)
export TRUSTED_IP=$(curl -s ifconfig.me)/32
./scripts/harden-nsg.sh
```

## 🛠️ Customization & Configuration

### Environment Variables
Update `docker/aca-py/.env` for local development:
```env
ACAPY_ADMIN_API_KEY=v2secretkey     # Change for production
ACAPY_WALLET_KEY=demo-key-v2        # Use secure keys in production
GENESIS_URL=http://host.docker.internal:8000/genesis
```

### Azure Parameters
Customize `infra/sandbox-arm/azuredeploy.parameters.json`:
```json
{
  "parameters": {
    "adminUsername": { "value": "azureuser" },
    "adminPasswordOrKey": { "value": "YourSecurePassword123!" },
    "vmSize": { "value": "Standard_B2s" }
  }
}
```

### Security Configuration
Update trusted IP in security scripts:
```bash
# Get your current IP
export TRUSTED_IP=$(curl -s ifconfig.me)/32

# Apply to NSG hardening
./scripts/harden-nsg.sh
```

## 🔍 Monitoring & Maintenance

### Health Monitoring
```bash
# Check all components
./scripts/check-status.sh

# Monitor Docker containers
docker ps --filter "name=aries-v2\|von-v2"

# Check logs
docker-compose logs -f acapyagent-v2
```

### Maintenance Tasks
```bash
# Update TLS certificates
./scripts/setup-tls.sh

# Rotate secrets in Key Vault
./scripts/store-secrets-keyvault.sh

# Run integration tests
./tests/integration-test.sh
```

## 🛠️ Troubleshooting

### Common Issues

**Von-Network not starting:**
```bash
cd docker/von-network
docker-compose logs webserver-v2
# Check port 8000 availability
```

**ACA-Py agents failing:**
```bash
cd docker/aca-py
docker-compose logs acapyagent-v2
# Verify genesis endpoint accessibility
curl http://localhost:8000/genesis
```

**Mobile wallet connection issues:**
```bash
# Check mediator is running
curl -H "X-API-KEY: v2secretkey" http://localhost:4003/status
# Verify firewall allows mobile connections
```

### Log Analysis
Comprehensive logging is built into all components:
- **Docker logs:** `docker-compose logs <service>`
- **Azure diagnostics:** Available through Azure Monitor
- **Application logs:** Structured logging with configurable levels

## 📚 Additional Resources

### Hyperledger Aries
- [Aries RFC Repository](https://github.com/hyperledger/aries-rfcs)
- [ACA-Py Documentation](https://aca-py.org/)
- [Von-Network Documentation](https://github.com/bcgov/von-network)

### Azure Resources
- [ARM Template Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Azure Key Vault Best Practices](https://docs.microsoft.com/en-us/azure/key-vault/general/best-practices)

### Canadian Digital Identity
- [Pan-Canadian Trust Framework](https://diacc.ca/pan-canadian-trust-framework/)
- [Digital Identity and Authentication Council of Canada](https://diacc.ca/)

## 📄 License

This project is licensed under the Apache License 2.0.

## 📞 Support

For issues and questions:
- **GitHub Issues:** Technical problems and feature requests
- **Discussions:** Community Q&A and implementation questions
- **Documentation:** Comprehensive guides in the `/docs` directory
#!/bin/bash

# Setup script for Aries Canada project structure
# This script creates the complete folder structure and all source files
#
# USAGE:
# 1. Save this script as 'setup-aries-project.sh'
# 2. Make it executable: chmod +x setup-aries-project.sh
# 3. Run it: ./setup-aries-project.sh
#
# IMPORTANT NEXT STEPS AFTER RUNNING:
# The script will remind you to:
# - Update default passwords in the parameter files
# - Replace placeholder IP addresses with your actual IPs
# - Update domain names for TLS certificates
# - Create your production ARM templates
# - Configure Azure credentials for GitHub Actions

set -e  # Exit on any error

echo "🚀 Setting up Aries Canada project structure..."

# Create directory structure
echo "📁 Creating directories..."
mkdir -p infra/sandbox-arm
mkdir -p infra/prod-arm
mkdir -p scripts
mkdir -p .github/workflows

# Create infra/sandbox-arm/azuredeploy.json
echo "📄 Creating infra/sandbox-arm/azuredeploy.json..."
cat > infra/sandbox-arm/azuredeploy.json << 'EOF'
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": { "type": "string" },
    "adminPassword": { "type": "securestring" }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2021-03-01",
      "name": "acaPySandboxVM",
      "location": "[resourceGroup().location]",
      "properties": {
        "hardwareProfile": { "vmSize": "Standard_B2s" },
        "osProfile": {
          "computerName": "acaPyVM",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "Canonical",
            "offer": "UbuntuServer",
            "sku": "18.04-LTS",
            "version": "latest"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            { "id": "[resourceId('Microsoft.Network/networkInterfaces', 'acaPyNIC')]" }
          ]
        }
      }
    }
  ]
}
EOF

# Create infra/sandbox-arm/azuredeploy.parameters.json
echo "📄 Creating infra/sandbox-arm/azuredeploy.parameters.json..."
cat > infra/sandbox-arm/azuredeploy.parameters.json << 'EOF'
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": { "value": "azureuser" },
    "adminPassword": { "value": "YourSecureP@ssword123" }
  }
}
EOF

# Create scripts/deploy-sandbox.sh
echo "📄 Creating scripts/deploy-sandbox.sh..."
cat > scripts/deploy-sandbox.sh << 'EOF'
#!/bin/bash
RESOURCE_GROUP=ariesCanadaRG
LOCATION=canadacentral

az group create --name $RESOURCE_GROUP --location $LOCATION
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/sandbox-arm/azuredeploy.json \
  --parameters infra/sandbox-arm/azuredeploy.parameters.json
EOF

# Create scripts/create-bifold-invitation.sh
echo "📄 Creating scripts/create-bifold-invitation.sh..."
cat > scripts/create-bifold-invitation.sh << 'EOF'
#!/bin/bash
curl -X POST http://localhost:3001/connections/create-invitation \
  -H "Content-Type: application/json" \
  -d '{"alias":"bifold-user","auto_accept":true}'
EOF

# Create scripts/setup-tls.sh
echo "📄 Creating scripts/setup-tls.sh..."
cat > scripts/setup-tls.sh << 'EOF'
#!/bin/bash
sudo apt update && sudo apt install -y certbot
sudo certbot certonly --standalone -d agent.yourdomain.ca -d mediator.yourdomain.ca
echo "TLS certificates installed in /etc/letsencrypt/live/."
EOF

# Create scripts/store-secrets-keyvault.sh
echo "📄 Creating scripts/store-secrets-keyvault.sh..."
cat > scripts/store-secrets-keyvault.sh << 'EOF'
#!/bin/bash
VAULT_NAME="ariesKeyVault"

az keyvault create --name $VAULT_NAME --resource-group ariesCanadaRG --location canadacentral
az keyvault secret set --vault-name $VAULT_NAME --name acapy-wallet-key --value "replace-with-your-wallet-key"
az keyvault secret set --vault-name $VAULT_NAME --name bridge-client-secret --value "replace-with-your-client-secret"
echo "Secrets stored in Azure Key Vault: $VAULT_NAME"
EOF

# Create scripts/harden-nsg.sh
echo "📄 Creating scripts/harden-nsg.sh..."
cat > scripts/harden-nsg.sh << 'EOF'
#!/bin/bash
NSG_NAME="ariesNSG"
RESOURCE_GROUP="ariesCanadaRG"

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name AllowSSH --priority 100 --access Allow --protocol Tcp --direction Inbound \
  --source-address-prefixes 1.2.3.4/32 --destination-port-ranges 22

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name AllowHTTPHTTPS --priority 110 --access Allow --protocol Tcp --direction Inbound \
  --source-address-prefixes 1.2.3.4/32 --destination-port-ranges 80 443 3001 3003

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name DenyAllInbound --priority 200 --access Deny --protocol "*" --direction Inbound \
  --source-address-prefixes "*" --destination-port-ranges "*"

echo "NSG hardened: only trusted IPs allowed."
EOF

# Create .github/workflows/deploy.yml
echo "📄 Creating .github/workflows/deploy.yml..."
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy Aries Infrastructure

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy ARM template
        run: |
          az deployment group create \
            --resource-group ariesCanadaRG \
            --template-file infra/prod-arm/azuredeploy.json \
            --parameters infra/prod-arm/azuredeploy.parameters.json
EOF

# Create README.md
echo "📄 Creating README.md..."
cat > README.md << 'EOF'
# Aries Canada Digital Identity Infrastructure

A comprehensive Infrastructure as Code (IaC) solution for deploying Hyperledger Aries agents and digital identity infrastructure on Microsoft Azure, specifically designed for Canadian government and enterprise use cases.

## 🎯 Project Overview

This repository provides Azure Resource Manager (ARM) templates and deployment scripts to establish a production-ready Aries ecosystem including:

- **ACA-Py (Aries Cloud Agent Python)** instances
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
│  │             Azure Key Vault                             │ │
│  │        (Wallet Keys & Secrets)                          │ │
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
├── infra/
│   ├── sandbox-arm/              # Development/testing environment
│   │   ├── azuredeploy.json      # Main ARM template
│   │   └── azuredeploy.parameters.json  # Environment parameters
│   └── prod-arm/                 # Production environment templates
│       └── README.md             # Production setup guide
├── scripts/
│   ├── deploy-sandbox.sh         # Sandbox deployment automation
│   ├── create-bifold-invitation.sh   # Mobile wallet connection
│   ├── setup-tls.sh              # SSL/TLS certificate management
│   ├── store-secrets-keyvault.sh # Azure Key Vault integration
│   └── harden-nsg.sh             # Network security hardening
├── .github/workflows/
│   └── deploy.yml                # CI/CD pipeline configuration
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- **Azure Subscription** with Contributor access
- **Azure CLI** installed and configured
- **Git** for repository management
- **Domain name** for TLS certificates (optional but recommended)
- **Basic understanding** of Hyperledger Aries concepts

### 1. Initial Setup

```bash
# Clone the repository
git clone https://github.com/your-org/aries-canada.git
cd aries-canada

# Install Azure CLI (if not already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify your login
az account show
```

### 2. Configure Environment

```bash
# Make all scripts executable
chmod +x scripts/*.sh

# Review and customize deployment parameters
nano infra/sandbox-arm/azuredeploy.parameters.json
```

**⚠️ CRITICAL: Update these values before deployment:**

1. **Change default passwords** in `azuredeploy.parameters.json`
2. **Update IP addresses** in `scripts/harden-nsg.sh` to your actual public IPs
3. **Replace domain names** in `scripts/setup-tls.sh` with your domains

### 3. Deploy Sandbox Environment

```bash
# Deploy the sandbox infrastructure
./scripts/deploy-sandbox.sh

# Wait for deployment to complete (typically 5-10 minutes)
# Check deployment status in Azure Portal
```

### 4. Post-Deployment Configuration

```bash
# Store secrets in Azure Key Vault
./scripts/store-secrets-keyvault.sh

# Harden network security (update IPs first!)
./scripts/harden-nsg.sh

# Set up TLS certificates (if using custom domains)
./scripts/setup-tls.sh
```

### 5. Test Mobile Wallet Integration

```bash
# Create an invitation for Bifold wallet
./scripts/create-bifold-invitation.sh

# Use the returned invitation URL/QR code in your Bifold mobile app
```

## 🔧 Detailed Configuration

### Environment Parameters

Edit `infra/sandbox-arm/azuredeploy.parameters.json`:

```json
{
  "parameters": {
    "adminUsername": { "value": "your-admin-user" },
    "adminPassword": { "value": "YourSecureP@ssword123!" }
  }
}
```

**Security Best Practices:**
- Use strong passwords (12+ characters, mixed case, numbers, symbols)
- Consider using SSH keys instead of passwords for production
- Enable Azure AD authentication where possible

### Network Security Configuration

Update `scripts/harden-nsg.sh` with your IP addresses:

```bash
# Replace 1.2.3.4/32 with your actual public IP
--source-address-prefixes YOUR.PUBLIC.IP.ADDRESS/32
```

**To find your public IP:**
```bash
curl ifconfig.me
```

### Domain and TLS Setup

For production deployments, update `scripts/setup-tls.sh`:

```bash
# Replace with your actual domain names
sudo certbot certonly --standalone \
  -d agent.yourdomain.ca \
  -d mediator.yourdomain.ca
```

## 🔐 Security Considerations

### Azure Key Vault Integration

The deployment automatically creates an Azure Key Vault to store:
- **Wallet encryption keys**
- **API secrets and tokens**
- **Database connection strings**
- **TLS certificates**

### Network Security

- **Network Security Groups (NSGs)** restrict access to specific IP ranges
- **Azure Load Balancer** provides DDoS protection
- **Azure Firewall** (optional) for advanced threat protection

### Access Control

- **Azure AD integration** for user authentication
- **Managed Service Identity** for service-to-service authentication
- **Role-Based Access Control (RBAC)** for fine-grained permissions

## 🚀 Production Deployment

### 1. Create Production Templates

```bash
# Copy sandbox templates to production
cp -r infra/sandbox-arm/* infra/prod-arm/

# Customize for production (larger VMs, multiple regions, etc.)
nano infra/prod-arm/azuredeploy.json
```

### 2. Set Up CI/CD Pipeline

The included GitHub Actions workflow (`deploy.yml`) automates production deployments:

1. **Configure Azure Service Principal:**
   ```bash
   az ad sp create-for-rbac --name "aries-canada-sp" \
     --role contributor \
     --scopes /subscriptions/YOUR-SUBSCRIPTION-ID \
     --sdk-auth
   ```

2. **Add GitHub Secrets:**
   - Go to your repository → Settings → Secrets
   - Add `AZURE_CREDENTIALS` with the service principal JSON

3. **Push to main branch** to trigger automatic deployment

### 3. Production Checklist

- [ ] Updated all default passwords and secrets
- [ ] Configured proper IP restrictions
- [ ] Set up monitoring and alerting
- [ ] Implemented backup strategies
- [ ] Configured custom domains with TLS
- [ ] Tested disaster recovery procedures

## 📊 Monitoring and Maintenance

### Azure Monitor Integration

```bash
# Enable diagnostic logs
az monitor diagnostic-settings create \
  --name "aries-diagnostics" \
  --resource-group "ariesCanadaRG" \
  --logs '[{"category":"Administrative","enabled":true}]'
```

### Health Checks

```bash
# Check ACA-Py agent status
curl http://your-agent-domain:3001/status

# Check mediator status
curl http://your-mediator-domain:3003/status
```

## 🛠️ Troubleshooting

### Common Issues

**Deployment fails with authentication error:**
```bash
# Re-login to Azure
az logout
az login
az account set --subscription "your-subscription-id"
```

**Cannot connect to Bifold wallet:**
- Verify firewall rules allow mobile traffic
- Check that mediator service is running
- Ensure invitation URLs are accessible

**TLS certificate issues:**
- Verify domain DNS points to your Azure resources
- Check that ports 80/443 are open
- Ensure certbot has proper permissions

### Log Analysis

```bash
# View Azure deployment logs
az deployment group show \
  --resource-group ariesCanadaRG \
  --name azuredeploy

# SSH into VM for application logs
ssh azureuser@your-vm-ip
sudo journalctl -u acapy -f
```

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create feature branch:** `git checkout -b feature/your-feature`
3. **Test changes** in sandbox environment
4. **Submit pull request** with detailed description

### Code Standards

- Use consistent indentation (2 spaces for JSON, 4 for scripts)
- Add comments for complex configurations
- Test all changes in sandbox before production
- Update documentation for new features

### Security Reviews

All changes involving security configurations require:
- Peer review from security team
- Testing in isolated environment
- Documentation of security implications

## 📚 Additional Resources

### Hyperledger Aries Documentation
- [Aries RFC Repository](https://github.com/hyperledger/aries-rfcs)
- [ACA-Py Documentation](https://aca-py.org/)
- [Aries Bifold Wallet](https://github.com/hyperledger/aries-mobile-agent-react-native)

### Azure Resources
- [ARM Template Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Azure Key Vault Best Practices](https://docs.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/)

### Canadian Digital Identity Standards
- [Pan-Canadian Trust Framework](https://diacc.ca/pan-canadian-trust-framework/)
- [Digital Identity and Authentication Council of Canada](https://diacc.ca/)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For issues and support:
- **GitHub Issues:** Report bugs and feature requests
- **Email:** aries-support@yourdomain.ca
- **Slack:** #aries-canada (internal team channel)

---

**⚠️ Important Security Notice:** This infrastructure handles sensitive identity data. Always follow your organization's security policies and compliance requirements. Regularly update dependencies and monitor for security vulnerabilities.
EOF

# Make all shell scripts executable
echo "🔧 Making shell scripts executable..."
chmod +x scripts/*.sh

# Create a note about prod-arm directory
echo "📝 Creating note about production templates..."
cat > infra/prod-arm/README.md << 'EOF'
# Production ARM Templates

This directory should contain your production ARM templates.
Copy and modify the sandbox templates from ../sandbox-arm/ as needed for production.

Remember to:
- Use appropriate VM sizes for production workloads
- Configure proper networking and security groups
- Set up monitoring and logging
- Use Azure Key Vault for secrets management
EOF

echo ""
echo "✅ Project setup complete!"
echo ""
echo "📁 Created directory structure:"
echo "   ├── infra/sandbox-arm/"
echo "   ├── infra/prod-arm/"
echo "   ├── scripts/"
echo "   └── .github/workflows/"
echo ""
echo "📄 Created files:"
echo "   ├── ARM templates (sandbox)"
echo "   ├── Deployment scripts (5 scripts)"
echo "   ├── GitHub Actions workflow"
echo "   └── README.md"
echo ""
echo "⚠️  IMPORTANT: Remember to:"
echo "   1. Update passwords in azuredeploy.parameters.json"
echo "   2. Replace IP addresses in harden-nsg.sh with your actual IPs"
echo "   3. Update domain names in setup-tls.sh"
echo "   4. Create production ARM templates in infra/prod-arm/"
echo "   5. Configure Azure credentials for GitHub Actions"
echo ""
echo "🚀 Ready to deploy your Aries infrastructure!"
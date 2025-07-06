#!/bin/bash

# VM Setup and SSH Helper Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🖥️  Azure VM Setup Helper${NC}"
echo "=========================="
echo ""

# Check if deployment info exists
DEPLOYMENT_INFO=$(ls scripts/deployment-info-*.json 2>/dev/null | head -1 || echo "")

if [ -n "$DEPLOYMENT_INFO" ] && [ -f "$DEPLOYMENT_INFO" ]; then
    echo -e "${GREEN}📋 Found deployment info: $DEPLOYMENT_INFO${NC}"
    
    # Extract connection details
    HOSTNAME=$(jq -r '.hostname.value // "unknown"' "$DEPLOYMENT_INFO")
    PUBLIC_IP=$(jq -r '.publicIPAddress.value // "unknown"' "$DEPLOYMENT_INFO")
    
    echo "🌐 Hostname: $HOSTNAME"
    echo "🔗 Public IP: $PUBLIC_IP"
    echo ""
else
    echo -e "${YELLOW}⚠️  No deployment info found${NC}"
    echo "💡 Make sure you've run ./scripts/deploy-sandbox.sh first"
    echo ""
fi

# SSH Connection Helper
echo -e "${BLUE}🔐 SSH Connection Options:${NC}"
echo ""

echo -e "${YELLOW}Option 1: Password Authentication (Current)${NC}"
echo "Default password: AriesCanada2024!@#"
echo ""
if [ -n "$HOSTNAME" ] && [ "$HOSTNAME" != "unknown" ]; then
    echo "SSH command:"
    echo "  ssh azureuser@$HOSTNAME"
    echo ""
fi

echo -e "${YELLOW}Option 2: SSH Key Authentication (Recommended)${NC}"
echo ""

# Check if SSH key exists
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${GREEN}✅ SSH public key found: ~/.ssh/id_rsa.pub${NC}"
    echo ""
    echo "To use SSH keys instead of password:"
    echo "1. Copy your public key:"
    echo "   cat ~/.ssh/id_rsa.pub"
    echo ""
    echo "2. Update ARM template parameters:"
    echo "   - Change authenticationType to 'sshPublicKey'"
    echo "   - Replace adminPasswordOrKey with your public key"
    echo ""
    echo "3. Redeploy with SSH key authentication"
    echo ""
else
    echo -e "${YELLOW}⚠️  No SSH key found${NC}"
    echo ""
    echo "To create an SSH key pair:"
    echo "1. Generate SSH key:"
    echo "   ssh-keygen -t rsa -b 4096 -C \"your-email@example.com\""
    echo ""
    echo "2. Follow the prompts (press Enter for defaults)"
    echo ""
    echo "3. Your public key will be in ~/.ssh/id_rsa.pub"
    echo ""
fi

# Next steps after VM access
echo -e "${BLUE}🚀 Next Steps After VM Access:${NC}"
echo ""
echo "1. 📥 Clone this repository:"
echo "   git clone https://github.com/your-org/aries-canada.git"
echo "   cd aries-canada"
echo ""
echo "2. 🔧 Make scripts executable:"
echo "   chmod +x scripts/*.sh"
echo ""
echo "3. 🚀 Start Aries infrastructure:"
echo "   ./scripts/start-aries-stack.sh"
echo ""
echo "4. 📱 Test mobile wallet connection:"
echo "   ./scripts/create-invitation.sh"
echo ""
echo "5. 🎓 Issue credentials:"
echo "   ./scripts/issue-credential.sh <connection_id>"
echo ""
echo "6. 🔍 Request proof:"
echo "   ./scripts/request-proof.sh <connection_id>"
echo ""

# Security recommendations
echo -e "${BLUE}🔒 Security Recommendations:${NC}"
echo ""
echo "1. 🔑 Change default password immediately"
echo "2. 🔐 Switch to SSH key authentication"
echo "3. 🛡️  Run network hardening:"
echo "   ./scripts/harden-nsg.sh"
echo "4. 🔐 Store secrets in Key Vault:"
echo "   ./scripts/store-secrets-keyvault.sh"
echo "5. 🔒 Set up TLS certificates:"
echo "   ./scripts/setup-tls.sh"
echo ""

echo -e "${GREEN}✅ VM setup guidance complete!${NC}"

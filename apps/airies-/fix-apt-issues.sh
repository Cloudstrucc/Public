#!/bin/bash

echo "🔧 Fixing APT repository issues in ARM template..."

TEMPLATE_PATH="infra/sandbox-arm/azuredeploy.json"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ ARM template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📄 Creating backup..."
cp "$TEMPLATE_PATH" "$TEMPLATE_PATH.backup-$(date +%Y%m%d-%H%M%S)"

# Use Python to update with robust apt commands
python3 << 'PYTHON_EOF'
import json

with open('infra/sandbox-arm/azuredeploy.json', 'r') as f:
    template = json.load(f)

# Find and update the VM extension
for resource in template['resources']:
    if (resource.get('type') == 'Microsoft.Compute/virtualMachines/extensions' and 
        'installAriesStack' in str(resource.get('name', ''))):
        
        print(f"🔧 Updating extension: {resource.get('name', 'unknown')}")
        
        # Robust command with proper error handling
        robust_command = """#!/bin/bash
set -e

# Wait for system to be ready
echo "Waiting for system to be ready..."
sleep 30

# Set non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Clean and fix apt
echo "Cleaning apt cache..."
rm -rf /var/lib/apt/lists/*
apt-get clean

# Update with retries
echo "Updating package lists..."
for i in {1..3}; do
    apt-get update --fix-missing && break
    echo "Retry $i failed, waiting..."
    sleep 10
done

# Install packages with error handling
echo "Installing packages..."
apt-get install -y --fix-broken docker.io docker-compose jq curl git qrencode || {
    echo "Installation failed, trying recovery..."
    dpkg --configure -a
    apt-get update --fix-missing
    apt-get install -y docker.io docker-compose jq curl git qrencode
}

# Configure Docker
echo "Configuring Docker..."
systemctl enable docker
systemctl start docker
usermod -aG docker azureuser

# Verify installation
echo "Verifying installation..."
docker --version
docker-compose --version

echo "✅ Installation complete!"
"""
        
        resource['properties']['settings']['commandToExecute'] = robust_command.strip()
        print("✅ Extension updated with robust handling")
        break

with open('infra/sandbox-arm/azuredeploy.json', 'w') as f:
    json.dump(template, f, indent=2)

print("✅ ARM template updated!")
PYTHON_EOF

echo ""
echo "✅ APT issues fixed!"
echo "🚀 Now run: ./scripts/deploy-sandbox.sh"

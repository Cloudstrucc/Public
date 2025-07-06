#!/bin/bash

echo "🔧 Fixing ARM template JSON structure..."

TEMPLATE_PATH="infra/sandbox-arm/azuredeploy.json"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ ARM template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📄 Backing up original template..."
cp "$TEMPLATE_PATH" "$TEMPLATE_PATH.backup"

# Use Python to fix the JSON structure properly
python3 << 'PYTHON_SCRIPT'
import json

# Read the ARM template
with open('infra/sandbox-arm/azuredeploy.json', 'r') as f:
    template = json.load(f)

# Find and fix the VM extension
for resource in template['resources']:
    if (resource.get('type') == 'Microsoft.Compute/virtualMachines/extensions' and 
        ('installDocker' in str(resource.get('name', '')) or 
         'installAriesStack' in str(resource.get('name', '')))):
        
        print(f"🔧 Fixing extension: {resource.get('name', 'unknown')}")
        
        # Fix the extension with correct JSON structure
        resource['properties'] = {
            "publisher": "Microsoft.Azure.Extensions",
            "type": "CustomScript", 
            "typeHandlerVersion": "2.1",
            "autoUpgradeMinorVersion": True,
            "settings": {
                "commandToExecute": "apt-get update && apt-get install -y docker.io docker-compose jq curl git qrencode && systemctl enable docker && systemctl start docker && usermod -aG docker azureuser"
            }
        }
        
        print("✅ Extension fixed")
        break

# Write the updated template
with open('infra/sandbox-arm/azuredeploy.json', 'w') as f:
    json.dump(template, f, indent=2)

print("✅ ARM template structure fixed!")
PYTHON_SCRIPT

echo ""
echo "✅ JSON structure fixed!"
echo "🚀 Now run: ./scripts/deploy-sandbox.sh"

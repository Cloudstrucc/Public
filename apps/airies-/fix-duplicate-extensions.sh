#!/bin/bash

echo "🔧 Fixing duplicate VM extensions in ARM template..."

TEMPLATE_PATH="infra/sandbox-arm/azuredeploy.json"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ ARM template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📄 Creating backup..."
cp "$TEMPLATE_PATH" "$TEMPLATE_PATH.backup-$(date +%Y%m%d-%H%M%S)"

# Use Python to fix duplicate extensions
python3 << 'PYTHON_EOF'
import json

with open('infra/sandbox-arm/azuredeploy.json', 'r') as f:
    template = json.load(f)

print("🔍 Analyzing VM extensions...")

# Separate VM extensions from other resources
extensions = []
other_resources = []

for resource in template['resources']:
    if resource.get('type') == 'Microsoft.Compute/virtualMachines/extensions':
        extensions.append(resource)
        print(f"   Found extension: {resource.get('name', 'unknown')}")
    else:
        other_resources.append(resource)

print(f"📊 Found {len(extensions)} VM extension(s)")

# Remove all extensions and add only one clean one
clean_extension = {
    "type": "Microsoft.Compute/virtualMachines/extensions",
    "apiVersion": "2021-03-01",
    "name": "[concat(variables('vmName'), '/installAriesStack')]",
    "location": "[parameters('location')]",
    "dependsOn": [
        "[resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))]"
    ],
    "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.1",
        "autoUpgradeMinorVersion": True,
        "settings": {
            "commandToExecute": "apt-get update && apt-get install -y docker.io docker-compose jq curl git qrencode && systemctl enable docker && systemctl start docker && usermod -aG docker azureuser"
        }
    }
}

# Rebuild resources with only one extension
template['resources'] = other_resources + [clean_extension]

with open('infra/sandbox-arm/azuredeploy.json', 'w') as f:
    json.dump(template, f, indent=2)

print("✅ Fixed! Now only one VM extension exists")
PYTHON_EOF

echo ""
echo "✅ Duplicate extensions fixed!"
echo "🚀 Now run: ./scripts/deploy-sandbox.sh"

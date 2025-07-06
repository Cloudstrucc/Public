#!/bin/bash

echo "🔧 Applying definitive ARM template fix..."

TEMPLATE_PATH="infra/sandbox-arm/azuredeploy.json"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ ARM template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📄 Creating backup..."
cp "$TEMPLATE_PATH" "$TEMPLATE_PATH.backup-$(date +%Y%m%d-%H%M%S)"

# Use Python to completely rewrite the extension
python3 << 'PYTHON_EOF'
import json

with open('infra/sandbox-arm/azuredeploy.json', 'r') as f:
    template = json.load(f)

# Find and replace the problematic extension
for i, resource in enumerate(template['resources']):
    if (resource.get('type') == 'Microsoft.Compute/virtualMachines/extensions' and 
        ('installDocker' in str(resource.get('name', '')) or 
         'installAriesStack' in str(resource.get('name', '')))):
        
        print(f"🔧 Replacing extension: {resource.get('name', 'unknown')}")
        
        # Completely replace with clean structure
        template['resources'][i] = {
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
        break

# Save the fixed template
with open('infra/sandbox-arm/azuredeploy.json', 'w') as f:
    json.dump(template, f, indent=2)

print("✅ ARM template fixed!")
PYTHON_EOF

echo "✅ Template fixed! Now run: ./scripts/deploy-sandbox.sh"

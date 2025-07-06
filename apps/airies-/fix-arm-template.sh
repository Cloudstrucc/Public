#!/bin/bash

echo "🔧 Fixing ARM template Docker installation..."

# Path to the ARM template
TEMPLATE_PATH="infra/sandbox-arm/azuredeploy.json"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ ARM template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📄 Backing up original template..."
cp "$TEMPLATE_PATH" "$TEMPLATE_PATH.backup"

echo "🔧 Updating VM extension..."

# Use sed to replace the problematic extension
sed -i.bak '/"fileUris": \[/,/"commandToExecute"/c\
        "settings": {},\
        "protectedSettings": {\
          "commandToExecute": "apt-get update && apt-get install -y docker.io docker-compose jq curl git qrencode && systemctl enable docker && systemctl start docker && usermod -aG docker azureuser"\
        }' "$TEMPLATE_PATH"

echo "✅ ARM template fixed!"
echo "🚀 You can now run: ./scripts/deploy-sandbox.sh"

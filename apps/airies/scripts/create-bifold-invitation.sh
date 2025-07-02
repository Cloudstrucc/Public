#!/bin/bash

# =============================================================================
# Bifold Invitation Creator for Azure ACA-Py Agent
# =============================================================================
# This script creates connection invitations using the ACA-Py agent 
# running on your Azure VM.
#
# REQUIREMENTS:
# 1. ACA-Py must be running on your Azure VM (port 8021)
# 2. Azure NSG must allow traffic on ports 8020 and 8021
# 3. VM must have public IP configured
# =============================================================================

# Configuration
AZURE_VM_IP="52.228.36.102"
ACAPY_ADMIN_PORT="8021"
ACAPY_ENDPOINT_PORT="8020"

echo "=========================================="
echo "🚀 ACA-Py Bifold Invitation Creator"
echo "=========================================="
echo "Azure VM IP: $AZURE_VM_IP"
echo "Admin Port: $ACAPY_ADMIN_PORT"
echo ""

# Function to check if ACA-Py is running
check_acapy_status() {
    echo "🔍 Checking if ACA-Py is running..."
    
    STATUS_RESPONSE=$(curl -s --connect-timeout 3 --max-time 5 \
        http://${AZURE_VM_IP}:${ACAPY_ADMIN_PORT}/status 2>/dev/null)
    
    if [ $? -eq 0 ] && [ ! -z "$STATUS_RESPONSE" ]; then
        echo "✅ ACA-Py is running and responsive"
        return 0
    else
        echo "❌ ACA-Py is not responding"
        return 1
    fi
}

# Function to create invitation
create_invitation() {
    echo ""
    echo "📨 Creating connection invitation..."
    
    INVITATION_RESPONSE=$(curl -s -X POST \
        http://${AZURE_VM_IP}:${ACAPY_ADMIN_PORT}/connections/create-invitation \
        -H "Content-Type: application/json" \
        -d '{"alias":"bifold-user","auto_accept":true}' \
        --connect-timeout 10 --max-time 15)
    
    if [ $? -eq 0 ] && [ ! -z "$INVITATION_RESPONSE" ]; then
        echo "✅ Invitation created successfully!"
        echo ""
        echo "📋 Invitation Details:"
        echo "----------------------------------------"
        echo "$INVITATION_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$INVITATION_RESPONSE"
        echo "----------------------------------------"
        return 0
    else
        echo "❌ Failed to create invitation"
        return 1
    fi
}

# Function to show troubleshooting steps
show_troubleshooting() {
    echo ""
    echo "🔧 TROUBLESHOOTING STEPS:"
    echo "=========================================="
    echo ""
    echo "1. ✅ Check if ACA-Py is running on VM:"
    echo "   ssh azureuser@${AZURE_VM_IP}"
    echo "   ps aux | grep aca-py"
    echo ""
    echo "2. ✅ Start ACA-Py if not running:"
    echo "   source ~/aca-py-env/bin/activate"
    echo "   aca-py start \\"
    echo "     --admin 0.0.0.0 8021 \\"
    echo "     --admin-insecure-mode \\"
    echo "     --inbound-transport http 0.0.0.0 8020 \\"
    echo "     --outbound-transport http \\"
    echo "     --endpoint http://${AZURE_VM_IP}:8020 \\"
    echo "     --no-ledger \\"
    echo "     --auto-provision \\"
    echo "     --wallet-type basic \\"
    echo "     --wallet-name demo-wallet \\"
    echo "     --wallet-key demo-key \\"
    echo "     --log-level info"
    echo ""
    echo "3. ✅ Check Azure NSG rules allow ports 8020 & 8021:"
    echo "   az network nsg rule list --resource-group ariesCanadaRG --nsg-name acaPyNSG --output table"
    echo ""
    echo "4. ✅ Test direct connection:"
    echo "   curl http://${AZURE_VM_IP}:${ACAPY_ADMIN_PORT}/status"
    echo ""
    echo "5. ✅ Check VM is running:"
    echo "   az vm get-instance-view --resource-group ariesCanadaRG --name acaPySandboxVM --query 'instanceView.statuses' --output table"
}

# Main execution
echo "Starting invitation creation process..."
echo ""

# Check ACA-Py status first
if ! check_acapy_status; then
    echo ""
    echo "⚠️  ACA-Py is not responding. Please check the troubleshooting steps below."
    show_troubleshooting
    exit 1
fi

# Create invitation
if create_invitation; then
    echo ""
    echo "🎉 SUCCESS! Use the invitation above to connect your Bifold wallet."
    echo ""
    echo "💡 Next steps:"
    echo "   1. Copy the 'invitation_url' from above"
    echo "   2. Open it in Bifold mobile app or scan QR code"
    echo "   3. Accept the connection in Bifold"
    echo ""
else
    echo ""
    echo "⚠️  Failed to create invitation. Check troubleshooting steps below."
    show_troubleshooting
    exit 1
fi
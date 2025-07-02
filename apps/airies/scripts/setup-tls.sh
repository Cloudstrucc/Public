#!/bin/bash

echo "Setting up for HTTP testing (no TLS required)"

# Detect operating system
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    OS="unknown"
fi

echo "Detected OS: $OS"

# Get the public IP
if command -v curl &> /dev/null; then
    PUBLIC_IP=$(curl -s http://ifconfig.me)
elif command -v wget &> /dev/null; then
    PUBLIC_IP=$(wget -qO- http://ifconfig.me)
else
    echo "Neither curl nor wget found. Please install one of them."
    PUBLIC_IP="YOUR_VM_PUBLIC_IP"
fi

echo "Public IP: $PUBLIC_IP"

# Get Azure FQDN if Azure CLI is available
if command -v az &> /dev/null; then
    FQDN=$(az network public-ip show \
        --resource-group ariesCanadaRG \
        --name acaPyPublicIP \
        --query dnsSettings.fqdn \
        --output tsv 2>/dev/null)
else
    echo "Azure CLI not found - skipping FQDN lookup"
fi

echo ""
echo "=== YOUR TEST ENDPOINTS ==="
echo "Agent URL: http://$PUBLIC_IP:8080"
echo "Mediator URL: http://$PUBLIC_IP:8081"

if [ ! -z "$FQDN" ]; then
    echo ""
    echo "Alternative using Azure FQDN:"
    echo "Agent URL: http://$FQDN:8080"
    echo "Mediator URL: http://$FQDN:8081"
fi

echo ""
echo "=== FIREWALL SETUP ==="
echo "Make sure these ports are open in Azure NSG:"
echo "- Port 8080 (Agent)"
echo "- Port 8081 (Mediator)"
echo "- Port 22 (SSH)"

# System-specific setup
case $OS in
    "linux")
        if command -v apt &> /dev/null; then
            echo ""
            echo "=== UPDATING UBUNTU SYSTEM ==="
            sudo apt update
            echo "Ubuntu system updated"
        elif command -v yum &> /dev/null; then
            echo ""
            echo "=== UPDATING RHEL/CENTOS SYSTEM ==="
            sudo yum update -y
            echo "RHEL/CentOS system updated"
        else
            echo "Linux detected but no known package manager found"
        fi
        ;;
    "mac")
        echo ""
        echo "=== MAC DETECTED ==="
        echo "This script appears to be running on macOS."
        echo "If you need to run system updates on your Azure VM:"
        echo "1. SSH to your VM: ssh azureuser@$PUBLIC_IP"
        echo "2. Run: sudo apt update && sudo apt upgrade -y"
        
        if command -v brew &> /dev/null; then
            echo ""
            echo "Homebrew detected. You can install Azure CLI with:"
            echo "brew install azure-cli"
        fi
        ;;
    "windows")
        echo ""
        echo "=== WINDOWS DETECTED ==="
        echo "This script appears to be running on Windows."
        echo "If you need to run system updates on your Azure VM:"
        echo "1. SSH to your VM: ssh azureuser@$PUBLIC_IP"
        echo "2. Run: sudo apt update && sudo apt upgrade -y"
        echo ""
        echo "Consider using Windows Subsystem for Linux (WSL) or install Azure CLI:"
        echo "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows"
        ;;
    *)
        echo ""
        echo "=== UNKNOWN OS ==="
        echo "Could not detect operating system."
        echo "To update your Azure VM, SSH in and run:"
        echo "ssh azureuser@$PUBLIC_IP"
        echo "sudo apt update && sudo apt upgrade -y"
        ;;
esac

echo ""
echo "=== SETUP COMPLETE ==="
echo "Your VM is ready for HTTP-based testing!"
echo "No TLS certificates needed for this setup."

if [ "$OS" != "linux" ]; then
    echo ""
    echo "NOTE: To configure your Azure VM, SSH into it:"
    echo "ssh azureuser@$PUBLIC_IP"
fi
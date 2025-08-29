#!/bin/bash

# Fix Node.js Installation Conflicts on macOS
# This script resolves common Node.js/npm conflicts when using Homebrew

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Fixing Node.js installation conflicts..."

# Check current Node.js installations
print_status "Checking current Node.js installations..."

echo "Current Node.js version (if any):"
node --version 2>/dev/null || echo "Node.js not found in PATH"

echo "Current npm version (if any):"
npm --version 2>/dev/null || echo "npm not found in PATH"

echo "Checking for existing Node.js installations:"
which node 2>/dev/null || echo "Node.js not in PATH"
which npm 2>/dev/null || echo "npm not in PATH"

# Clean up conflicting files
print_warning "Cleaning up conflicting Node.js files..."

# Remove the conflicting npm symlinks
if [ -L "/usr/local/bin/npm" ]; then
    print_status "Removing conflicting npm symlink..."
    sudo rm -f /usr/local/bin/npm
fi

if [ -L "/usr/local/bin/npx" ]; then
    print_status "Removing conflicting npx symlink..."
    sudo rm -f /usr/local/bin/npx
fi

# Fix permissions for npm global directory
print_status "Fixing npm permissions..."
if [ -d "/usr/local/lib/node_modules" ]; then
    sudo chown -R $(whoami):admin /usr/local/lib/node_modules
    sudo chmod -R 755 /usr/local/lib/node_modules
fi

# Create corepack directory with correct permissions
if [ ! -d "/usr/local/lib/node_modules/corepack" ]; then
    print_status "Creating corepack directory..."
    sudo mkdir -p /usr/local/lib/node_modules/corepack
    sudo chown -R $(whoami):admin /usr/local/lib/node_modules/corepack
fi

# Force link Node.js with overwrite
print_status "Force linking Node.js through Homebrew..."
brew link --overwrite node || {
    print_error "Failed to link Node.js. Trying alternative approach..."
    
    # Alternative: Uninstall and reinstall Node.js cleanly
    print_status "Uninstalling existing Node.js..."
    brew uninstall --ignore-dependencies node 2>/dev/null || true
    
    print_status "Cleaning up any remaining files..."
    sudo rm -rf /usr/local/lib/node_modules
    sudo rm -f /usr/local/bin/node
    sudo rm -f /usr/local/bin/npm  
    sudo rm -f /usr/local/bin/npx
    
    print_status "Reinstalling Node.js cleanly..."
    brew install node
}

# Verify installation
print_status "Verifying Node.js installation..."
node --version
npm --version

# Fix npm permissions globally
print_status "Setting up proper npm permissions..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Add to PATH if not already there
if ! echo $PATH | grep -q "$HOME/.npm-global/bin"; then
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
    export PATH=~/.npm-global/bin:$PATH
fi

# Install Yarn globally
print_status "Installing Yarn globally..."
npm install -g yarn

print_success "Node.js installation fixed!"

# Now continue with MongoDB installation
print_status "Continuing with MongoDB installation..."
brew install mongodb-community

print_success "All installations completed successfully!"

echo ""
echo "===================================================="
echo "  Node.js Installation Fixed!"
echo "===================================================="
echo ""
print_status "Versions installed:"
echo "- Node.js: $(node --version)"
echo "- npm: $(npm --version)"
echo "- Yarn: $(yarn --version)"
echo ""
print_warning "Important: You may need to restart your terminal or run:"
echo "source ~/.zshrc"
echo ""
print_status "Now you can continue with the main setup script."
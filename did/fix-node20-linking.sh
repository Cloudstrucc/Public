#!/bin/bash

# Alternative Node.js Fix - Bypasses Homebrew linking issues
# Uses direct paths and manual configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_status "Alternative Node.js setup (bypassing Homebrew linking)..."

# Check if Node@20 is installed
if [ ! -d "/usr/local/Cellar/node@20" ]; then
    print_error "Node@20 not found. Please run: brew install node@20"
    exit 1
fi

print_success "Node@20 found in Homebrew cellar"

# Method 1: Use direct paths (no linking required)
print_status "Setting up direct Node@20 paths..."

# Find the exact Node@20 version path
NODE_VERSION=$(ls /usr/local/Cellar/node@20/ | head -n 1)
NODE_PATH="/usr/local/Cellar/node@20/$NODE_VERSION"
NODE_BIN="$NODE_PATH/bin"

print_status "Using Node@20 path: $NODE_BIN"

# Clear existing Node paths from shell config
if [ -f ~/.zshrc ]; then
    print_status "Cleaning existing Node paths from ~/.zshrc..."
    # Create backup
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    
    # Remove existing node-related paths
    grep -v -E "(node|npm|yarn)" ~/.zshrc > ~/.zshrc.tmp 2>/dev/null || touch ~/.zshrc.tmp
    mv ~/.zshrc.tmp ~/.zshrc
fi

# Add Node@20 direct paths
print_status "Adding Node@20 direct paths to ~/.zshrc..."
cat >> ~/.zshrc << EOF

# Node@20 Direct Paths (bypass Homebrew linking)
export PATH="$NODE_BIN:\$PATH"
export NODE_PATH="$NODE_PATH"
export LDFLAGS="-L$NODE_PATH/lib"
export CPPFLAGS="-I$NODE_PATH/include"

# NPM Global Directory
export PATH="\$HOME/.npm-global/bin:\$PATH"
EOF

# Source the new configuration
print_status "Loading new PATH configuration..."
export PATH="$NODE_BIN:$PATH"
export NODE_PATH="$NODE_PATH"

# Verify Node.js is accessible
if [ -f "$NODE_BIN/node" ]; then
    print_success "Node.js found: $($NODE_BIN/node --version)"
else
    print_error "Node.js binary not found at expected location"
    exit 1
fi

# Verify npm is accessible
if [ -f "$NODE_BIN/npm" ]; then
    print_success "npm found: $($NODE_BIN/npm --version)"
else
    print_error "npm binary not found at expected location"
    exit 1
fi

# Setup npm global directory
print_status "Setting up npm global directory..."
mkdir -p ~/.npm-global
$NODE_BIN/npm config set prefix '~/.npm-global'

# Install Yarn globally using the direct npm path
print_status "Installing Yarn globally..."
$NODE_BIN/npm install -g yarn

# Check if Yarn was installed successfully
if [ -f ~/.npm-global/bin/yarn ]; then
    print_success "Yarn installed: $(~/.npm-global/bin/yarn --version)"
else
    print_warning "Yarn installation may not be complete"
fi

# Method 2: Create manual symlinks in user space (fallback)
print_status "Creating user-space symlinks as backup..."
mkdir -p ~/bin

ln -sf "$NODE_BIN/node" ~/bin/node 2>/dev/null || true
ln -sf "$NODE_BIN/npm" ~/bin/npm 2>/dev/null || true
ln -sf ~/.npm-global/bin/yarn ~/bin/yarn 2>/dev/null || true

# Add ~/bin to PATH if not already there
if ! grep -q "export PATH=.*~/bin" ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
fi

print_success "Node.js setup complete!"

echo ""
echo "===================================================="
echo "  Alternative Node.js Setup Complete!"
echo "===================================================="
echo ""
print_warning "RESTART YOUR TERMINAL NOW or run:"
echo "source ~/.zshrc"
echo ""
print_status "Then test with:"
echo "node --version"
echo "npm --version"
echo "yarn --version"
echo ""
print_status "If commands are not found, try:"
echo "$NODE_BIN/node --version"
echo "$NODE_BIN/npm --version"
echo "~/.npm-global/bin/yarn --version"
echo ""
print_status "After verification, continue with your project setup in did-cloud-signature-saas/"

# Test current session
echo ""
print_status "Testing in current session:"
echo "Node.js: $($NODE_BIN/node --version)"
echo "npm: $($NODE_BIN/npm --version)"
if [ -f ~/.npm-global/bin/yarn ]; then
    echo "Yarn: $(~/.npm-global/bin/yarn --version)"
else
    echo "Yarn: Installation pending - restart terminal"
fi
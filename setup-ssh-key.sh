#!/bin/bash

# SSH Key Setup Script for GitHub
# Creates Ed25519 SSH key and configures SSH for GitHub

set -e

echo "🔑 Setting up SSH key for GitHub authentication..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get user email (default to the one in git config)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
if [[ -n "$GIT_EMAIL" ]]; then
    read -p "Email for SSH key [$GIT_EMAIL]: " EMAIL
    EMAIL=${EMAIL:-$GIT_EMAIL}
else
    read -p "Email for SSH key: " EMAIL
fi

if [[ -z "$EMAIL" ]]; then
    print_error "Email is required!"
    exit 1
fi

# Check if SSH key already exists
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY_PATH" ]]; then
    print_warning "SSH key already exists at $SSH_KEY_PATH"
    read -p "Do you want to create a new one? This will overwrite the existing key (y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        print_info "Using existing SSH key..."
        if [[ -f "$SSH_KEY_PATH.pub" ]]; then
            print_info "Your public SSH key:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            cat "$SSH_KEY_PATH.pub"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
        echo ""
        print_info "Skip to step 6 below to add this key to GitHub if you haven't already."
        exit 0
    fi
fi

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

print_info "Creating Ed25519 SSH key..."
echo ""

# Generate SSH key
ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH" -N ""

print_status "SSH key created successfully!"

# Set proper permissions
chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_KEY_PATH.pub"

# Start SSH agent and add key
print_info "Starting SSH agent and adding key..."

# Check if ssh-agent is running
if ! pgrep -x ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add SSH key to agent
ssh-add "$SSH_KEY_PATH"

# Add to macOS Keychain
print_info "Adding SSH key to macOS Keychain..."
# ssh-add --apple-use-keychain "$SSH_KEY_PATH"

print_status "SSH key generation complete!"
echo ""

# Display public key for GitHub
print_info "Your public SSH key for GitHub:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$SSH_KEY_PATH.pub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_warning "SSH configuration should be managed through Nix!"
echo ""
print_info "Add this to your Nix configuration (e.g., ssh.nix module):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "programs.ssh = {"
echo "  enable = true;"
echo "  extraConfig = ''"
echo "    Host github.com"
echo "      HostName github.com"
echo "      User git"
echo "      IdentityFile ~/.ssh/id_ed25519"
echo "      AddKeysToAgent yes"
echo "      UseKeychain yes"
echo "  '';"
echo "};"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "Next steps:"
echo "1. Copy the public key above"
echo "2. Add the SSH configuration to your Nix setup (see ssh.nix module below)"
echo "3. Run: darwin-rebuild switch --flake ~/.config/nix"
echo "4. Add the public key to GitHub:"
echo "   - Go to GitHub Settings > SSH and GPG keys"
echo "   - Click 'New SSH key'"
echo "   - Paste the key and give it a title (e.g., 'MacBook Pro - $(date +%Y)')"
echo "5. Test the connection: ssh -T git@github.com"
echo "6. Try cloning again: git clone git@github.com:octoenergy/kraken-core.git"
echo ""
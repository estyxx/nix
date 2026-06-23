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
        print_info "If ssh -T git@github.com fails, add this key at https://github.com/settings/keys"
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

# Add SSH key to agent and macOS Keychain
print_info "Adding SSH key to agent and macOS Keychain..."
ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null || ssh-add "$SSH_KEY_PATH"

print_status "SSH key generation complete!"
echo ""

# Display public key for GitHub
print_info "Your public SSH key for GitHub:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$SSH_KEY_PATH.pub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_warning "Required: add this public key to GitHub (browser — cannot be automated)"
echo ""
print_info "Next steps (in order):"
echo "1. Open https://github.com/settings/keys → New SSH key"
echo "2. Paste the public key above; title e.g. '$(scutil --get LocalHostName 2>/dev/null || hostname) - $(date +%Y)'"
echo "3. Test: ssh-add --apple-use-keychain $SSH_KEY_PATH && ssh -T git@github.com"
echo "   (expect: Hi <user>! You've successfully authenticated…)"
echo "4. Then run darwin-rebuild (see README §7): sudo nix run github:LnL7/nix-darwin/master -- switch --flake \".#\$(scutil --get LocalHostName)\""
echo ""
print_info "SSH client config is applied by Nix after darwin-rebuild (modules/git.nix)."
echo ""

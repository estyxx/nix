#!/bin/bash

# GPG Setup Script for macOS with Keychain Integration
# This script helps set up GPG signing for Git commits with macOS Keychain integration

set -e

echo "🔐 Setting up GPG for Git signing with macOS Keychain integration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    print_error "GPG is not installed. Please install it first:"
    echo "  brew install gnupg pinentry-mac"
    exit 1
fi

# Check if pinentry-mac is installed
if ! command -v pinentry-mac &> /dev/null; then
    print_error "pinentry-mac is not installed. Please install it first:"
    echo "  brew install pinentry-mac"
    exit 1
fi

# Create GPG directory if it doesn't exist
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Step 1: Check if key already exists
KEY_ID="AF7EACF820CAEACD"
if gpg --list-secret-keys --keyid-format LONG | grep -q "$KEY_ID"; then
    print_status "GPG key $KEY_ID already exists in keyring"
else
    print_warning "GPG key $KEY_ID not found in keyring"
    echo "Please import your existing key or create a new one:"
    echo ""
    echo "To import an existing key:"
    echo "  gpg --import /path/to/your/private-key.asc"
    echo ""
    echo "To create a new key:"
    echo "  gpg --full-generate-key"
    echo ""
    echo "After importing/creating your key, run this script again."
    exit 1
fi

# Step 2: Configure GPG Agent for macOS Keychain
print_status "Configuring GPG Agent..."


# Step 3: Configure GPG
print_status "Configuring GPG..."




# Step 4: Restart GPG Agent
print_status "Restarting GPG Agent..."
gpgconf --kill gpg-agent
gpg-agent --daemon

# Step 5: Test GPG signing
print_status "Testing GPG signing..."
echo "test" | gpg --clearsign --default-key "$KEY_ID" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status "GPG signing test successful!"
else
    print_error "GPG signing test failed. Please check your configuration."
    exit 1
fi


# Step 7: Add GPG key to macOS Keychain (optional but recommended)
print_warning "To avoid entering your passphrase repeatedly, you can add it to macOS Keychain:"
echo ""
echo "1. Open Keychain Access"
echo "2. Create a new Generic Password item:"
echo "   - Name: GPG Passphrase"
echo "   - Account: $KEY_ID"
echo "   - Password: [your GPG key passphrase]"
echo ""
echo "Or run this command to add it programmatically:"
echo "  security add-generic-password -a '$KEY_ID' -s 'GPG Passphrase' -w"
echo ""

# Step 8: Export public key for GitHub
print_status "Exporting public key for GitHub..."
echo ""
echo "Here's your public GPG key to add to GitHub:"
echo "========================================"
gpg --armor --export "$KEY_ID"
echo "========================================"
echo ""
echo "To add this key to GitHub:"
echo "1. Go to GitHub Settings > SSH and GPG keys"
echo "2. Click 'New GPG key'"
echo "3. Paste the key above"
echo ""

# Step 9: Environment setup
print_status "Setting up environment..."

# Function to add GPG configuration to shell profiles (excluding Fish since it's managed by Nix)
add_gpg_config() {
    local profile_file="$1"
    local shell_type="$2"
    
    if [ -f "$profile_file" ]; then
        if ! grep -q "GPG_TTY" "$profile_file"; then
            echo "" >> "$profile_file"
            echo "# GPG configuration" >> "$profile_file"
            echo "export GPG_TTY=\$(tty)" >> "$profile_file"
            echo "export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)" >> "$profile_file"
            
            print_status "Added GPG environment variables to $profile_file"
            return 0
        else
            print_status "GPG configuration already exists in $profile_file"
            return 0
        fi
    fi
    return 1
}

# Add to shell profiles (excluding Fish since it's managed by Nix)
CONFIGURED_SHELLS=()

# Check if Fish is being used but managed by Nix
if command -v fish &> /dev/null; then
    print_status "Fish shell detected - GPG configuration should be managed through Nix"
    CONFIGURED_SHELLS+=("Fish (managed by Nix)")
fi

# Zsh
if add_gpg_config "$HOME/.zshrc" "zsh"; then
    CONFIGURED_SHELLS+=("Zsh")
fi

# Bash
if add_gpg_config "$HOME/.bash_profile" "bash"; then
    CONFIGURED_SHELLS+=("Bash (.bash_profile)")
elif add_gpg_config "$HOME/.bashrc" "bash"; then
    CONFIGURED_SHELLS+=("Bash (.bashrc)")
fi

if [ ${#CONFIGURED_SHELLS[@]} -eq 0 ]; then
    print_warning "No shell configuration files found. You may need to manually add:"
    echo "  For Zsh/Bash: export GPG_TTY=\$(tty)"
    echo "                export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)"
    echo "  For Fish: This should be configured in your Nix configuration"
else
    print_status "Configured shells: ${CONFIGURED_SHELLS[*]}"
fi

# Final instructions
echo ""
print_status "GPG setup complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Rebuild your Nix configuration to apply Fish GPG settings:"
echo "   darwin-rebuild switch --flake ~/.config/nix"
echo "2. For other shells, restart your terminal or reload your shell configuration:"
for shell in "${CONFIGURED_SHELLS[@]}"; do
    case $shell in
        "Fish (managed by Nix)")
            echo "   Fish: Reload after Nix rebuild"
            ;;
        "Zsh")
            echo "   Zsh: source ~/.zshrc"
            ;;
        "Bash"*)
            echo "   Bash: source ~/.bash_profile (or ~/.bashrc)"
            ;;
    esac
done
echo "3. Add your public key to GitHub (shown above)"
echo "4. Test with a signed commit: git commit -S -m 'Test signed commit'"
echo ""
if command -v fish &> /dev/null; then
    echo "After Nix rebuild, Fish shell users will have these helper functions:"
    echo "- gpg-restart: Restart the GPG agent"
    echo "- gpg-test: Test GPG signing functionality"
    echo "- gpg-status: Show GPG agent status"
    echo "- gcs: Git commit with signature"
    echo "- gcas: Git commit all with signature"
fi
echo ""
echo "If you encounter issues:"
echo "- Make sure pinentry-mac is properly installed"
echo "- Restart GPG agent: gpgconf --kill gpg-agent && gpg-agent --daemon"
echo "- Check GPG agent status: gpg-connect-agent 'keyinfo --list' /bye"
echo ""
print_warning "Remember to add your GPG passphrase to Keychain Access to avoid repeated prompts!"
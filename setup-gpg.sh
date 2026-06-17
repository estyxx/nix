#!/bin/bash

# GPG setup for macOS (Homebrew gnupg + pinentry-mac, gpg-agent, optional import).
#
# Fully automated path (no manual gpg --import in the terminal):
#   1. Put gpg-signing-key.asc next to setup-gpg.sh in this repo (chmod 600), then: ./setup-gpg.sh
#   2. Or copy to ~/.config/nix/gpg-signing-key.asc (only used if non-empty and valid).
#   3. Or: ./setup-gpg.sh /path/to/private-key.asc
#   Or: NIX_GPG_IMPORT=/path/to/key.asc ./setup-gpg.sh
#
# Search order: first CLI arg, then NIX_GPG_IMPORT, then repo gpg-signing-key.asc,
# then ~/.config/nix/gpg-signing-key.asc (empty files are skipped).
#
# Optional: NIX_GPG_KEY_ID=keyid   (default: Kraken work signing key id from modules/machines.nix)

set -euo pipefail

echo "🔐 Setting up GPG for Git signing with macOS Keychain integration..."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

ensure_homebrew_on_path() {
    if command -v brew &>/dev/null; then
        return 0
    fi
    local brew_path
    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_path" ]]; then
            # shellcheck disable=SC1090
            eval "$("$brew_path" shellenv)"
            return 0
        fi
    done
    return 1
}

ensure_gpg_packages() {
    if command -v gpg &>/dev/null && command -v pinentry-mac &>/dev/null; then
        return 0
    fi

    if ! ensure_homebrew_on_path; then
        print_error "Homebrew is not installed (or not on PATH). Install it first, then re-run this script:"
        echo ""
        echo "  https://brew.sh"
        echo ""
        exit 1
    fi

    print_warning "Installing gnupg and pinentry-mac via Homebrew (you may be prompted for your password)..."
    brew install gnupg pinentry-mac

    if ! command -v gpg &>/dev/null; then
        for gpg_path in /opt/homebrew/bin/gpg /usr/local/bin/gpg; do
            if [[ -x "$gpg_path" ]]; then
                export PATH="$(dirname "$gpg_path"):$PATH"
                break
            fi
        done
    fi

    if ! command -v gpg &>/dev/null || ! command -v pinentry-mac &>/dev/null; then
        print_error "brew install finished but gpg or pinentry-mac is still not on PATH."
        echo "  Open a new terminal and run this script again, or run: eval \"\$(brew shellenv)\""
        exit 1
    fi
    print_status "gnupg and pinentry-mac are available"
}

write_gpg_agent_conf() {
    local pinentry conf
    pinentry=$(command -v pinentry-mac) || {
        print_error "pinentry-mac not on PATH"
        return 1
    }
    conf="$HOME/.gnupg/gpg-agent.conf"
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"

    if [[ -f "$conf" ]] && grep -q '^pinentry-program ' "$conf"; then
        sed -i '' "s|^pinentry-program .*|pinentry-program $pinentry|" "$conf"
    else
        echo "pinentry-program $pinentry" >>"$conf"
    fi

    if ! grep -q '^default-cache-ttl ' "$conf" 2>/dev/null; then
        echo "default-cache-ttl 600" >>"$conf"
    fi
    if ! grep -q '^max-cache-ttl ' "$conf" 2>/dev/null; then
        echo "max-cache-ttl 7200" >>"$conf"
    fi

    print_status "pinentry-program set in $conf"
}

restart_gpg_agent() {
    gpgconf --kill gpg-agent 2>/dev/null || true
    gpg-agent --daemon
}

# First usable path: CLI arg, env, repo gpg-signing-key.asc, then ~/.config/nix/
# (empty files are skipped so a stale zero-byte ~/.config/nix file does not shadow the repo).
resolve_secret_key_path() {
    local first_arg="${1:-}"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)" || script_dir=""
    local default_repo="$script_dir/gpg-signing-key.asc"
    local default_config="$HOME/.config/nix/gpg-signing-key.asc"
    local candidate
    for candidate in "$first_arg" "${NIX_GPG_IMPORT:-}" "$default_repo" "$default_config"; do
        if [[ -n "$candidate" && -f "$candidate" && -s "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

try_import_secret_key() {
    local path
    if ! path=$(resolve_secret_key_path "${1:-}"); then
        return 0
    fi
    print_warning "Importing secret key from: $path"
    if gpg --import "$path"; then
        print_status "gpg finished reading $path"
    else
        print_error "gpg could not read a valid OpenPGP key from: $path"
        echo ""
        echo "Check the file is a GnuPG secret key export (e.g. output of: gpg --export-secret-keys --armor <keyid>)."
        echo "If ~/.config/nix/gpg-signing-key.asc is wrong or empty, remove it or put the real key in"
        echo "gpg-signing-key.asc next to setup-gpg.sh and run this script again."
        exit 1
    fi
}

secret_key_present() {
    local key_id="$1"
    if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "$key_id"; then
        return 0
    fi
    return 1
}

ensure_gpg_packages

mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

write_gpg_agent_conf
restart_gpg_agent

KEY_ID="${NIX_GPG_KEY_ID:-AF7EACF820CAEACD}"

if secret_key_present "$KEY_ID"; then
    print_status "GPG key $KEY_ID already exists in keyring"
else
    try_import_secret_key "${1:-}"
    restart_gpg_agent
fi

if ! secret_key_present "$KEY_ID"; then
    print_error "Secret key for $KEY_ID is not in the keyring."
    echo ""
    echo "Automated import (first match wins: arg, NIX_GPG_IMPORT, repo gpg-signing-key.asc, then ~/.config/nix/; empty files ignored):"
    echo "  install -m 600 /Volumes/your-backup/signing.asc ./gpg-signing-key.asc   # next to setup-gpg.sh"
    echo "  ./setup-gpg.sh"
    echo ""
    echo "Or: install -m 600 /real/path/backup.asc \"$HOME/.config/nix/gpg-signing-key.asc\" && ./setup-gpg.sh"
    echo ""
    echo "Or pass the file: ./setup-gpg.sh /path/to/your/backup.asc"
    echo "Or: NIX_GPG_IMPORT=/path/to/your/backup.asc ./setup-gpg.sh"
    echo ""
    echo "Wrong NIX_GPG_KEY_ID? Export the fingerprint from the machine that has the key:"
    echo "  gpg --list-secret-keys --keyid-format LONG"
    exit 1
fi

print_status "Configuring GPG Agent and GPG defaults..."

GPG_CONF="$HOME/.gnupg/gpg.conf"
if [[ ! -f "$GPG_CONF" ]] || ! grep -q '^use-agent' "$GPG_CONF" 2>/dev/null; then
    {
        echo "use-agent"
        echo "default-key $KEY_ID"
    } >>"$GPG_CONF"
    print_status "Appended use-agent and default-key to $GPG_CONF"
fi

restart_gpg_agent

print_status "Testing GPG signing..."
if echo "test" | gpg --clearsign --default-key "$KEY_ID" >/dev/null 2>&1; then
    print_status "GPG signing test successful!"
else
    print_error "GPG signing test failed. Check pinentry and passphrase."
    exit 1
fi

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

print_status "Setting up environment..."

add_gpg_config() {
    local profile_file="$1"

    if [ -f "$profile_file" ]; then
        if ! grep -q "GPG_TTY" "$profile_file"; then
            echo "" >>"$profile_file"
            echo "# GPG configuration" >>"$profile_file"
            echo "export GPG_TTY=\$(tty)" >>"$profile_file"
            echo "export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)" >>"$profile_file"

            print_status "Added GPG environment variables to $profile_file"
            return 0
        else
            print_status "GPG configuration already exists in $profile_file"
            return 0
        fi
    fi
    return 1
}

CONFIGURED_SHELLS=()

if command -v fish &>/dev/null; then
    print_status "Fish shell detected - GPG configuration should be managed through Nix"
    CONFIGURED_SHELLS+=("Fish (managed by Nix)")
fi

if add_gpg_config "$HOME/.zshrc"; then
    CONFIGURED_SHELLS+=("Zsh")
fi

if add_gpg_config "$HOME/.bash_profile"; then
    CONFIGURED_SHELLS+=("Bash (.bash_profile)")
elif add_gpg_config "$HOME/.bashrc"; then
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
if command -v fish &>/dev/null; then
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

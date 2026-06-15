# Nix macOS Development Environment

Reproducible macOS setup using [Nix flakes](https://nixos.wiki/wiki/Flakes),
[nix-darwin](https://github.com/LnL7/nix-darwin), and
[home-manager](https://github.com/nix-community/home-manager). Manages Fish shell, dev
tools, Git/GPG signing, macOS defaults, and AeroSpace window tiling.

**Repo:** [github.com/estyxx/nix](https://github.com/estyxx/nix)

## What this configures

- **System:** dev packages (Python, PostgreSQL 17, Terraform, jq, etc.), Fish as default
  shell, macOS Finder/Dock/keyboard defaults
- **User:** Fish aliases and functions, Fisher plugins, Starship/fzf, Git with signed
  commits (work machines), SSH for GitHub
- **Window manager:** AeroSpace config with workspace rules for browsers, editors, dev
  tools, and messaging apps

See [CLAUDE.md](./CLAUDE.md) for module layout and [CONVENTIONS.md](./CONVENTIONS.md)
for coding standards.

---

## Configure a new Mac (full guide)

### 1. Prerequisites

- macOS on Apple Silicon (`aarch64-darwin`) or Intel (`x86_64-darwin`)
- Admin access on the machine
- Apple ID / iCloud set up (optional, for Keychain)

### 2. Install Nix

Install the [Nix package manager](https://nixos.org/download.html) (multi-user install
recommended).

Ensure flakes are enabled. Either use `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

Restart your terminal after installation.

### 3. Install Homebrew (recommended)

Many GUI apps and some CLI tools are still installed via Homebrew (Nix does not manage
casks yet):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install PATH instructions for your shell, then install common apps you
rely on (Arc, VS Code, 1Password, Postgres.app, etc.).

### 4. Clone this configuration

```bash
git clone https://github.com/estyxx/nix.git ~/.config/nix
cd ~/.config/nix
```

### 5. Register your machine

Find your hostname:

```bash
scutil --get LocalHostName
# or: hostname
```

Edit `modules/machines.nix` and add an entry:

```nix
{
  "Your-Hostname-Here" = {
    username = "your.macos.username";   # must match /Users/your.macos.username
    system = "aarch64-darwin";          # or x86_64-darwin for Intel Macs
    profile = "personal";               # or "kraken" for work
  };
}
```

For **work Macs** (Kraken / Octopus Energy), use:

```nix
"KT-MAC-XXXXXXXX" = {
  username = "first.last";
  system = "aarch64-darwin";
  profile = "kraken";
  git = {
    signingKey = "YOUR_GPG_KEY_ID";     # public key fingerprint, not the secret key
  };
};
```

### 6. Set up SSH and GPG (work Macs)

From the repo root:

```bash
./setup-ssh-key.sh    # creates ~/.ssh/id_ed25519, add .pub to GitHub
./setup-gpg.sh        # GPG agent + Keychain; import your signing key when prompted
```

Add the SSH public key at
[GitHub → Settings → SSH keys](https://github.com/settings/keys).

Test:

```bash
ssh -T git@github.com
gpg --list-secret-keys
```

### 7. Build and activate

Replace `Your-Hostname-Here` with the exact key from `machines.nix`:

```bash
cd ~/.config/nix

# Verify the flake evaluates
nix build .#darwinConfigurations.Your-Hostname-Here.system

# Apply system + home-manager config
sudo darwin-rebuild switch --flake .
```

First run may take several minutes while Nix downloads packages.

### 8. Verify

Open a **new** terminal tab:

```bash
echo $SHELL          # should end in /fish
fish --version
git config user.name
```

On work machines, confirm signed commits:

```bash
gpg-test             # Fish function from git.nix
git commit --allow-empty -m "test signing"
```

### 9. Optional: pre-commit hooks

```bash
cd ~/.config/nix
pre-commit install
```

---

## Day-to-day usage

```bash
cd ~/.config/nix

# After editing any .nix file
sudo darwin-rebuild switch --flake .

# Edit config in VS Code
nix-edit             # Fish alias → opens ~/.config/nix
```

### Updating dependencies

```bash
nix flake update
darwin-rebuild switch --flake .
```

---

## Project structure

```
flake.nix                 # Flake entry; one darwinConfiguration per machine
modules/
  machines.nix            # Machine registry
  mac.nix                 # macOS system settings
  common-packages.nix     # Shared packages
  git.nix                 # Git, GPG, SSH
  fish/                   # Fish shell, functions, AeroSpace
setup-ssh-key.sh          # SSH bootstrap
setup-gpg.sh              # GPG bootstrap
```

---

## Security

**Do not commit:**

- Private keys, API tokens, passwords, `.env` files
- Shell history (`modules/fish/fish_history` is gitignored)
- GPG private key exports

Use `local-config.nix` (gitignored) for machine-specific secrets or overrides.

Pre-commit hooks include private-key detection.

---

## Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)

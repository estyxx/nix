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

Follow the post-install PATH instructions for your shell.

See [Manual setup (not managed by Nix)](#manual-setup-not-managed-by-nix) for fonts, GUI
apps, Homebrew packages, and Cursor extensions.

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

# After editing any .nix / .toml / .fish file in this repo
sudo darwin-rebuild switch --flake .

# Edit config in your editor
nix-edit             # Fish alias → opens ~/.config/nix
```

### What Nix manages vs what you manage

- **Nix (this repo):** Fish shell, Git/GPG, Starship, AeroSpace, macOS defaults, dev CLI
  tools
- **asdf (Homebrew):** Python, Node, Ruby, etc. — use `.tool-versions` per project
- **Homebrew (manual):** GUI apps + kraken `inv install-system-deps` packages

Do **not** edit `~/.config/fish/config.fish` or other home-manager files directly — they
are read-only symlinks into the Nix store. Edit sources here, then rebuild. No sudo
needed for editing (only for `darwin-rebuild switch`).

See [CONVENTIONS.md](./CONVENTIONS.md) for the full split.

---

## Manual setup (not managed by Nix)

Homebrew, fonts, GUI apps, and kraken system deps are **intentionally outside** this
flake. Nix-homebrew was removed because `cleanup = "zap"` conflicted with
`inv install-system-deps`.

### Fonts

Nix installs nerd-font variants to `/Library/Fonts/Nix Fonts/` (see `modules/mac.nix`):

- Fira Code Nerd Font, Fira Mono Nerd Font, Hack Nerd Font Mono, JetBrains Mono Nerd
  Font

Cursor settings use:

| Setting                            | Font                  | Source                             |
| ---------------------------------- | --------------------- | ---------------------------------- |
| `terminal.integrated.fontFamily`   | Hack Nerd Font Mono   | Nix (automatic after rebuild)      |
| `editor.fontFamily` (first choice) | Fira Code Two iScript | **Manual** — not in Nix nerd-fonts |

Install **Fira Code Two iScript** manually (the italic/ligature variant Cursor prefers):

```bash
# Option A: copy from an existing Mac (files in ~/Library/Fonts/)
#   FiraCodeTwoiScript-Regular.ttf
#   FiraCodeTwoiScript-Bold.ttf
#   FiraCodeTwoiScript-Italic.ttf

# Option B: plain Fira Code via Homebrew (fallback only — not Two iScript)
brew install --cask font-fira-code
```

Plain `FiraCode-*.ttf` files in `~/Library/Fonts/` are fallbacks listed after Two
iScript in `settings-kraken.json`.

### Docker

macOS needs **Docker Desktop** for the daemon — the Nix `docker` / `docker-compose`
packages in `common-packages.nix` are CLI tools only and do not start an engine.

```bash
brew install --cask docker
# open Docker.app once; enable "Start Docker Desktop when you log in" if you want
```

On kraken work Macs, also install the ECR credential helper (already in the brew list
below) so `docker pull` from AWS ECR works without manual `aws ecr get-login`.

Fish aliases `d` / `dc` and `DOCKER_BUILDKIT=1` are set in `modules/fish/fish.nix`.
AeroSpace puts Docker Desktop on workspace 9 (`modules/aerospace.toml`).

### Homebrew — all machines

```bash
brew install asdf direnv starship
```

Add asdf to Fish (already in `fish-user.nix` if Homebrew is at `/opt/homebrew`):

```bash
asdf plugin add python
asdf plugin add nodejs
# per project: asdf install && asdf local <tool> <version>
```

### Homebrew — work Macs (Kraken)

CLI tools commonly installed outside Nix:

```bash
brew install kraken-cli k9s kubectx kubernetes-cli helm aws-iam-authenticator \
  memcached libmemcached libxmlsec1 openssl@1.1 sops codeowners \
  docker-credential-helper-ecr watchexec uv

brew install --cask 1password-cli claude claude-code gitkraken-cli
```

Then install kraken system dependencies from the repo (authoritative list):

```bash
cd ~/Projects/kraken-core
inv install-system-deps
```

Do **not** re-enable nix-homebrew cleanup — it removes packages invoke installed.

### GUI apps

Dock pins in `modules/mac.nix` expect these `.app` installs (Homebrew cask or manual
download):

| App            | Typical install                                                  |
| -------------- | ---------------------------------------------------------------- |
| Arc            | `brew install --cask arc`                                        |
| Cursor         | [cursor.com](https://cursor.com) or `brew install --cask cursor` |
| AeroSpace      | `brew install --cask nikitabobko/tap/aerospace`                  |
| Warp           | `brew install --cask warp`                                       |
| Fork           | [git-fork.com](https://git-fork.com)                             |
| Postgres.app   | `brew install --cask postgres-unofficial`                        |
| 1Password      | `brew install --cask 1password`                                  |
| Slack          | `brew install --cask slack`                                      |
| Docker Desktop | `brew install --cask docker` (see [Docker](#docker) above)       |

### Cursor extensions (work profile)

User settings live in Nix (`modules/cursor/settings-kraken.json`). Extension
recommendations are listed in `modules/cursor/extensions-kraken.json` (mirrors
`kraken-core/my.code-workspace`).

Install once on a new work Mac:

```bash
for ext in charliermarsh.ruff ms-python.python ms-python.debugpy \
  ms-python.vscode-pylance esbenp.prettier-vscode rioj7.command-variable; do
  cursor --install-extension "$ext"
done
```

**Keep in `my.code-workspace` (project-specific, not user config):**

- Python analysis paths (`src/`, migrations excludes), pytest args, `cursorpyright`
  paths
- Django Fluent locale paths, `mypy.dmypyExecutable`, `search.exclude`
- Launch configs (Support Site / API Site debug), invoke tasks, `window.title` with
  branch

Opening `kraken-core` merges workspace settings on top of user settings.

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

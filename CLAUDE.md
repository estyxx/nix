# CLAUDE.md — AI guide for this repo

Personal macOS dev environment managed with **Nix flakes**, **nix-darwin**, and
**home-manager**. Fish shell, Git/GPG signing, AeroSpace window manager, and Kraken Core
work shortcuts.

See [CONVENTIONS.md](./CONVENTIONS.md) for coding standards (Nix, Fish, file placement).

## Repository layout

```
flake.nix                      # Entry point; darwinConfigurations + formatter
modules/
  machines.nix                 # Machine registry (hostname → username, system, profile)
  machines/work.nix              # home-manager: kraken profile aliases
  machines/personal.nix          # home-manager: personal profile overrides
  mac.nix                        # nix-darwin: Nix settings, fonts, macOS defaults
  common-packages.nix            # System-wide packages
  git.nix                        # Git, GPG, SSH, Fish crypto/SSH helpers
  aerospace.nix                  # deploys modules/aerospace.toml → ~/.aerospace.toml
  aerospace.toml                 # AeroSpace window manager config
  fish/
    fish.nix                     # System Fish + env vars + Homebrew PATH
    fish-user.nix                # Shared Fish aliases and shell init
    fish-functions.nix           # Deploys ./fish-functions/*.fish (kraken only)
    fish-functions/              # Source of truth for Fish functions
    fisher-plugins.nix           # Nix-managed Fish plugins (z, done)
setup-ssh-key.sh                 # One-time SSH bootstrap
setup-gpg.sh                     # One-time GPG bootstrap
Brewfile                         # Homebrew bundle: brew bundle install
CONVENTIONS.md                   # Coding standards for this repo
```

Remote: `https://github.com/estyxx/nix` — clone to `~/.config/nix`.

## Machine profiles

Each host in `modules/machines.nix` defines:

| Field            | Purpose                                                          |
| ---------------- | ---------------------------------------------------------------- |
| `username`       | macOS login name (used in home paths and Nix profile)            |
| `system`         | `aarch64-darwin` (Apple Silicon) or `x86_64-darwin` (Intel)      |
| `profile`        | `"personal"` or `"kraken"` — controls imports and Fish functions |
| `git.signingKey` | Optional GPG key ID (kraken machines only)                       |

Profile modules are imported conditionally in `flake.nix`:

- `profile = "kraken"` → `machines/work.nix` + all `fish-functions/*.fish`
- `profile = "personal"` → `machines/personal.nix`, no kraken Fish functions, no GPG
  signing

## Common commands

```bash
cd ~/.config/nix

# Format Nix (RFC style via flake formatter)
nix fmt

# Build without applying
nix build .#darwinConfigurations.<HostName>.system

# Apply configuration
sudo darwin-rebuild switch --flake .

# Pre-commit
pre-commit install
pre-commit run --all-files
```

## Where to change things

| Goal                       | File                                                 |
| -------------------------- | ---------------------------------------------------- |
| Add a new Mac              | `modules/machines.nix`                               |
| System packages            | `modules/common-packages.nix`                        |
| macOS UI / dock / defaults | `modules/mac.nix`                                    |
| Fish alias (all machines)  | `modules/fish/fish-user.nix`                         |
| Fish alias (work only)     | `modules/machines/work.nix`                          |
| Fish function (kraken)     | `modules/fish/fish-functions/*.fish`                 |
| AeroSpace                  | `modules/aerospace.toml`                             |
| Git identity, signing, SSH | `modules/git.nix`                                    |
| Kraken auto-env on `cd`    | `modules/fish/fish-functions/kraken_core_setup.fish` |

After editing `.nix` files: `nix fmt` then `darwin-rebuild switch --flake .`.

## Architecture notes

- **flake.nix** maps `machines.nix` entries to `darwinConfiguration` via
  `mkDarwinSystem`.
- **home-manager** imports: `fishUser`, `fishFunctions`, `fisherPlugins`, `aerospace`,
  `git`, plus profile module.
- `machineConfig` is passed via `_module.args` for username/profile branching.
- **Fish functions** are deployed via `home.file` in `fish-functions.nix`, not inline in
  `fish-user.nix`.
- **Homebrew** is not managed by Nix; GUI apps are installed manually.

## Security — never commit

Private keys, tokens, `.env`, shell history, GPG secret exports. See CONVENTIONS.md.

## Known gaps

- Homebrew casks in `mac.nix` are commented out.
- `machines/personal.nix` is a stub — add personal-only config there as needed.

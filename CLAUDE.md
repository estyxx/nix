# CLAUDE.md — AI guide for this repo

Personal macOS dev environment managed with **Nix flakes**, **nix-darwin**, and
**home-manager**. Fish shell, Git/GPG signing, AeroSpace window manager, and Kraken Core
work shortcuts.

## Repository layout

```
flake.nix                 # Entry point; generates darwinConfigurations per machine
modules/
  machines.nix            # Machine registry (hostname → username, system, profile)
  machines/personal.nix   # Stub for personal-only overrides (not yet wired into flake)
  machines/work.nix       # Stub for work-only overrides (not yet wired into flake)
  mac.nix                 # nix-darwin: Nix settings, fonts, macOS defaults, dock
  common-packages.nix     # System-wide packages (dev tools, Python, Terraform, etc.)
  git.nix                 # Git, GPG, SSH, pre-commit, commit template
  fish/
    fish.nix              # System Fish + env vars + Homebrew PATH
    fish-user.nix         # Home-manager Fish: aliases, functions, shell init
    fisher-plugins.nix    # Fisher plugins + ~/.aerospace.toml
    fish-functions/       # Standalone .fish files (also referenced from fish-user.nix)
setup-ssh-key.sh          # One-time SSH key bootstrap for GitHub
setup-gpg.sh              # One-time GPG + Keychain bootstrap
```

Remote: `https://github.com/estyxx/nix` — clone to `~/.config/nix`.

## Machine profiles

Each host in `modules/machines.nix` defines:

| Field            | Purpose                                                            |
| ---------------- | ------------------------------------------------------------------ |
| `username`       | macOS login name (used in home paths and Nix profile)              |
| `system`         | `aarch64-darwin` (Apple Silicon) or `x86_64-darwin` (Intel)        |
| `profile`        | `"personal"` or `"kraken"` — controls Git URL rewrites and signing |
| `git.signingKey` | Optional GPG/SSH signing key ID (work machines only)               |

Get hostname: `scutil --get LocalHostName` or `hostname`.

## Common commands

```bash
# From repo root (~/.config/nix)
cd ~/.config/nix

# Build without applying (dry run)
nix build .#darwinConfigurations.<HostName>.system

# Apply configuration (preferred after first install)
sudo darwin-rebuild switch --flake .

# Or via build result
./result/sw/bin/darwin-rebuild switch --flake .

# Format Nix files
nixfmt modules/**/*.nix flake.nix

# Pre-commit (install once per clone)
pre-commit install
pre-commit run --all-files
```

Replace `<HostName>` with the exact key from `machines.nix` (e.g. `KT-MAC-D32YJC7C9P`).

## Where to change things

| Goal                             | File                                                 |
| -------------------------------- | ---------------------------------------------------- |
| Add a new Mac                    | `modules/machines.nix`                               |
| System packages                  | `modules/common-packages.nix`                        |
| macOS UI / dock / defaults       | `modules/mac.nix`                                    |
| Fish aliases & inline functions  | `modules/fish/fish-user.nix`                         |
| Fish functions as separate files | `modules/fish/fish-functions/*.fish`                 |
| AeroSpace workspaces & bindings  | `modules/fish/fisher-plugins.nix`                    |
| Git identity, signing, SSH       | `modules/git.nix`                                    |
| Kraken auto-env on `cd`          | `modules/fish/fish-functions/kraken_core_setup.fish` |

After editing `.nix` files, run `darwin-rebuild switch --flake .`.

Fish function files under `fish-functions/` are deployed by home-manager when referenced
from `fish-user.nix` or `fisher-plugins.nix`; check those modules for how each file is
included.

## Architecture notes

- **flake.nix** maps every entry in `machines.nix` to a `darwinConfiguration` via
  `mkDarwinSystem`.
- **home-manager** runs per-user (`home-manager.users.${username}`) and imports
  `fish-user`, `fisherPlugins`, and `git`.
- `machineConfig` is passed through `_module.args` so modules can branch on
  profile/username.
- **Homebrew** is not managed by Nix (nix-homebrew is commented out). Homebrew apps are
  referenced in macOS defaults and AeroSpace rules; install them manually or via
  Brewfile elsewhere.
- **Signing**: `profile = "kraken"` machines need `git.signingKey`; personal machines
  omit it and GPG signing is disabled in git config.

## Kraken / work development

Work-specific pieces:

- `kraken_core_setup.fish` — sets `KRAKEN_CLIENT`, `DJANGO_CONFIGURATION`, venv on
  entering kraken-core
- `fish-user.nix` — `test_prodcat`, `pt`, `pri`, `cdk`, `pcrun`, teamsearch aliases
- `git.nix` — rewrites `https://github.com/octoenergy/` → SSH for kraken profile

These assume kraken-core lives at `~/Projects/kraken-core` and a venv at
`~/.virtualenvs/kraken-core`.

## Security — never commit

- Private keys, `.env`, tokens, passphrases, `*.pem`, `id_rsa`, `id_ed25519` (without
  `.pub`)
- **Shell history** — `modules/fish/fish_history` was removed from tracking; do not
  re-add
- `local-config.nix` (gitignored) for machine-local overrides
- Real GPG private key exports

Safe to commit: GPG **key IDs** (public fingerprints), email, hostnames, usernames.

Pre-commit runs `detect-private-key` on staged files.

## Adding a new machine (checklist)

1. Install Nix with flakes enabled (`nix.conf` has
   `experimental-features = nix-command flakes`).
2. Clone repo to `~/.config/nix`.
3. Add entry to `modules/machines.nix` with correct `username` and `system`.
4. For work Macs: set `profile = "kraken"` and `git.signingKey`; run `./setup-gpg.sh`
   and `./setup-ssh-key.sh`.
5. `nix build .#darwinConfigurations.<HostName>.system` then
   `darwin-rebuild switch --flake .`.
6. Open a new terminal (Fish should be default shell).

## Known gaps / tech debt

- `modules/machines/personal.nix` and `work.nix` are stubs and **not imported** in
  `flake.nix` yet — per-profile config still lives in shared modules.
- `git.nix` hardcodes GPG default key in `~/.gnupg/gpg.conf` (work key); personal
  machines skip commit signing but still get gpg.conf.
- Homebrew casks in `mac.nix` are commented out; apps are installed outside Nix.
- README clone path is `~/.config/nix` (not `nix-config`).

## Conventions for AI edits

- Match existing Nix style; run `nixfmt` on changed `.nix` files.
- Prefer extending existing modules over new top-level files.
- Use `machineConfig` for username/profile-specific logic instead of hardcoding paths.
- Fish functions: add to `fish-user.nix` `functions` attrset or as `.fish` in
  `fish-functions/`.
- Keep commits focused; this repo uses pre-commit hooks (trailing whitespace, private
  key detection, nixfmt, prettier for markdown).
- Do not commit secrets or shell history.

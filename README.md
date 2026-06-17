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

Ensure flakes are enabled. **`sudo nix` only reads `/etc/nix/nix.conf`** (root’s home is
`/var/root`, not your login). `~/.config/nix/nix.conf` is enough for **your**
`nix build` as a normal user, but the **first nix-darwin switch is usually run with
`sudo`**, so put flakes in the **system** config too (or pass flags as shown in
[§7](#7-build-and-activate)):

```ini
experimental-features = nix-command flakes
```

Typical location (create the directory if needed):

```bash
sudo mkdir -p /etc/nix
printf '%s\n' 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
```

You can keep the same line in `~/.config/nix/nix.conf` for day-to-day non-sudo use.

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

Edit `modules/machines.nix` and add an entry. The **left-hand string** in quotes (the
attribute name) must be the same name you pass to `nix build` / `darwin-rebuild` as
`#that-name` (example below uses `NIXHOST`). It is often equal to `LocalHostName`, but
you can pick any unique string as long as it matches the commands you run.

```nix
{
  "Your-Mac-Name" = {
    username = "your.macos.username";   # must match /Users/your.macos.username
    system = "aarch64-darwin";            # or x86_64-darwin for Intel Macs
    profile = "personal";
  };
}
```

For **work Macs** (Kraken / Octopus Energy), add `profile = "kraken"` and
`git.signingKey`:

```nix
{
  "KT-MAC-XXXXXXXX" = {
    username = "first.last";
    system = "aarch64-darwin";
    profile = "kraken";
    git = {
      signingKey = "YOUR_GPG_KEY_ID";   # public key fingerprint, not the secret key
    };
  };
}
```

### 6. Set up SSH and GPG (work Macs)

From the repo root:

```bash
./setup-ssh-key.sh    # creates ~/.ssh/id_ed25519, add .pub to GitHub
./setup-gpg.sh        # installs gnupg + pinentry-mac if needed, configures agent, imports signing key
```

#### GPG: you must bring the **secret key** from another machine

Git signing needs your **private** key material on this Mac. Nix cannot invent it. You
**export once** on a PC that already has the key, **copy the file** out-of-band (never
commit it), then `setup-gpg.sh` **imports** it here.

**On the Mac (or PC) that already has your signing key**

1. Confirm the key id (must match `git.signingKey` / `machines.nix` for this machine):

   ```bash
   gpg --list-secret-keys --keyid-format LONG
   ```

2. Export the **secret** key to a file (example uses **armor** so the file is plain
   text; you can omit `--armor` for a smaller binary file — both work with
   `setup-gpg.sh`):

   ```bash
   gpg --export-secret-keys --armor YOUR_KEY_ID > gpg-signing-key.asc
   chmod 600 gpg-signing-key.asc
   ```

   Replace `YOUR_KEY_ID` with the id from step 1 (often the `sec` line looks like
   `rsa4096/YOUR_KEY_ID`).

3. **Move that file to the new Mac** using something you trust (AirDrop, encrypted USB,
   `scp` over SSH, a password manager attachment, etc.). Treat it like a password:
   anyone with the file can impersonate your Git signatures until you rotate the key.

**On the new Mac**

1. Put the file in **one** of these places (then run `./setup-gpg.sh`):

   - **`gpg-signing-key.asc` next to `setup-gpg.sh`** in this repo (recommended), or
   - **`~/.config/nix/gpg-signing-key.asc`**, or
   - Pass the path: `./setup-gpg.sh /path/to/gpg-signing-key.asc`, or
   - `NIX_GPG_IMPORT=/path/to/file.asc ./setup-gpg.sh`

2. **Search order** (first non-empty file wins): CLI argument → `NIX_GPG_IMPORT` → repo
   `gpg-signing-key.asc` → `~/.config/nix/gpg-signing-key.asc`.

3. Optional: **`NIX_GPG_KEY_ID=<id>`** if the key you imported is not the default
   expected by this script (work Kraken machines use the id in `machines.nix`).

`setup-gpg.sh` needs [Homebrew](https://brew.sh); it installs `gnupg` and `pinentry-mac`
when missing and writes `~/.gnupg/gpg-agent.conf`.

#### Security: key **id** vs secret **file**

- The **signing key id** (hex fingerprint fragment in `machines.nix` / Git
  `user.signingkey`) is **not a secret**. It identifies your **public** key and shows up
  on signed commits and GitHub anyway.
- The **`gpg-signing-key.asc`** produced by `--export-secret-keys` **is secret**. It
  must **never** be committed. This repo **gitignores** `gpg-signing-key.asc`; keep
  using that exact filename so you do not accidentally track it.

Add the SSH public key at
[GitHub → Settings → SSH keys](https://github.com/settings/keys).

Test:

```bash
ssh -T git@github.com
gpg --list-secret-keys
```

### 7. Build and activate

Use the **same quoted name** you used as the attribute key in `modules/machines.nix`
(for example `"KT-MAC-D32YJC7C9P"`). Set it once per shell session (use **your** name,
not a placeholder):

```bash
export NIXHOST="KT-MAC-D32YJC7C9P"
cd ~/.config/nix
```

Check that the flake evaluates (no `sudo`):

```bash
nix build ".#darwinConfigurations.${NIXHOST}.system"
```

**`nix build` succeeding does not install nix-darwin.** Until you run the **bootstrap**
below, **`darwin-rebuild` does not exist** — `sudo darwin-rebuild` will print
`command not found`. That is expected.

**Before bootstrap:** ensure **`/etc/nix/nix.conf`** enables flakes (see
[§2](#2-install-nix)). Without it, `sudo nix run …` fails with
`experimental Nix feature 'nix-command' is disabled` because root does not use your
`~/.config/nix/nix.conf`.

**If nix-darwin refuses with “Unexpected files in /etc”**, it will not overwrite unknown
`/etc/nix/nix.conf`, `/etc/bashrc`, or `/etc/zshrc`. **Rename** them (do not blindly
`rm` — especially keep a copy of any custom `nix.conf` lines you care about), then run
bootstrap again:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
```

Then restore flakes for root (nix-darwin will manage this file after activation):

```bash
sudo mkdir -p /etc/nix
printf '%s\n' 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
```

**Bootstrap (first activation — run as root):** `darwin-rebuild` may print “activation
must now be run as root”; run the whole thing under **`sudo`**. Flags belong **right
after `nix`**, not after `run`:

```bash
cd ~/.config/nix
export NIXHOST="KT-MAC-D32YJC7C9P"
sudo nix --extra-experimental-features "nix-command flakes" run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

If `/etc/nix/nix.conf` already has `experimental-features = nix-command flakes`, you can
omit the `--extra-experimental-features …` part:

```bash
sudo nix run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

When that finishes, open a **new** terminal tab; then `darwin-rebuild` should be on your
`PATH`.

If Nix prints **Git tree … is dirty**, the build can still succeed; it only means you
have uncommitted changes. To hide the warning: add `warn-dirty = false` to your
[`nix.conf`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html), or pass
`--option warn-dirty false` to `nix build` / `nix run` for a one-off.

**After bootstrap** (every later config change):

```bash
cd ~/.config/nix
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

If `sudo darwin-rebuild switch --flake .` works on your machine without `#hostname`, you
can use that instead; with **multiple** machines in `machines.nix`, prefer an explicit
`.#${NIXHOST}`.

**If `nix build` says the attribute does not exist**, the name in the command does not
match the left-hand string in `machines.nix` (typo, or you never added this Mac).

**If `zsh: command not found: #`**, you pasted a “comment” line that is not a real shell
comment (often a fancy Unicode `#` from a PDF or web page). Re-type `#` manually or copy
only the fenced **bash** blocks above, one at a time.

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

sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

If **`darwin-rebuild: command not found`**, you have not finished the **bootstrap** in
[§7 Build and activate](#7-build-and-activate) yet — run the `sudo nix … run … switch`
command there once, then open a new terminal.

If **`nix-command` / `flakes` disabled** under `sudo`, add them to
**`/etc/nix/nix.conf`** (see §2 and §7) or use
`sudo nix --extra-experimental-features "nix-command flakes" run …` (flags **immediately
after `nix`**, not at the end of the line).

Set `NIXHOST` to the same `machines.nix` key as in [§7](#7-build-and-activate) (or use
`sudo darwin-rebuild switch --flake .` if that works on your machine). After editing any
`.nix` / `.toml` / `.fish` file in this repo, run the command above.

```bash
nix-edit             # Fish alias → opens ~/.config/nix (after Fish is default shell)
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
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
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

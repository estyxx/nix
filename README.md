# Nix macOS Development Environment

Reproducible macOS setup using [Nix flakes](https://nixos.wiki/wiki/Flakes),
[nix-darwin](https://github.com/LnL7/nix-darwin), and
[home-manager](https://github.com/nix-community/home-manager). Fish shell, dev tools,
Git/GPG (work), macOS defaults, and AeroSpace tiling.

**Repo:** [github.com/estyxx/nix](https://github.com/estyxx/nix) — clone to
`~/.config/nix`.

See [CLAUDE.md](./CLAUDE.md) for module layout and [CONVENTIONS.md](./CONVENTIONS.md)
for coding standards.

---

## What this configures

- **System:** dev packages, Fish as default shell, Finder/Dock/keyboard defaults
  (`modules/mac.nix`)
- **User:** Fish + declarative plugins (`modules/fish/fish-plugins.nix`: done, fzf-fish,
  forgit, sponge, …), optional Oh My Fish (`modules/fish/omf.nix`), Starship, Git
  (signed commits on work profile), SSH helpers
- **Window manager:** AeroSpace (`modules/aerospace.toml`)

---

## New Mac setup

Do these in order. **Personal Mac:** skip step 7 (GPG). **Work (kraken):** do all steps.

### 1. Install Nix and enable flakes

Install [Nix](https://nixos.org/download.html) (multi-user). Then:

```bash
sudo mkdir -p /etc/nix
printf '%s\n' 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
```

Restart the terminal.

### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the `eval "$(…/brew shellenv)"` line the installer prints.

### 3. Clone this repo

```bash
git clone https://github.com/estyxx/nix.git ~/.config/nix
cd ~/.config/nix
```

### 4. Add this Mac to `modules/machines.nix`

Hostname (must match the quoted key in the file):

```bash
scutil --get LocalHostName
```

Personal example:

```nix
"Your-LocalHostName" = {
  username = "you.shorthost";  # whoami
  system = "aarch64-darwin";
  profile = "personal";
};
```

Work (kraken): `profile = "kraken"` and `git.signingKey = "HEXID";` — see existing
entries in `machines.nix`.

Commit and push if you edited on another machine first; on a fresh clone, edit locally
before step 8.

### 5. Create an SSH key

Each Mac needs its own key. GitHub only trusts keys you paste in the browser — importing
GPG does not help here.

```bash
cd ~/.config/nix
./setup-ssh-key.sh
```

### 6. Add the SSH key to GitHub

Copy the public key the script printed (or `cat ~/.ssh/id_ed25519.pub`).

1. [github.com/settings/keys](https://github.com/settings/keys) → **New SSH key**
2. Paste the full `ssh-ed25519 …` line, save

Test before continuing:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh -T git@github.com
```

Expect: `Hi estyxx! You've successfully authenticated…`

### 7. Import GPG signing key (work / kraken only)

Skip on personal Macs (`profile = "personal"`).

On a machine that already has the key:

```bash
gpg --export-secret-keys --armor KEYID > gpg-signing-key.asc
```

Copy the file to this Mac (never commit — gitignored), then:

```bash
cd ~/.config/nix
./setup-gpg.sh
```

### 8. Build and activate nix-darwin

From `~/.config/nix`. `NIXHOST` must match the key in `modules/machines.nix`:

```bash
cd ~/.config/nix
export NIXHOST="$(scutil --get LocalHostName)"
echo "NIXHOST=$NIXHOST"
nix build ".#darwinConfigurations.${NIXHOST}.system"
```

First install only (until `darwin-rebuild` exists):

```bash
sudo nix run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

If `sudo nix` says flakes are disabled:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

Open a **new terminal** when it finishes. Later config changes:

```bash
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

**Fish** — same commands; set host first:

```fish
cd ~/.config/nix
set -gx NIXHOST (scutil --get LocalHostName)
nix build ".#darwinConfigurations.$NIXHOST.system"
sudo nix run github:LnL7/nix-darwin/master -- switch --flake ".#$NIXHOST"
sudo darwin-rebuild switch --flake ".#$NIXHOST"
```

Use double quotes around flake refs in Fish so `#` is not a comment.

### 9. Set Fish as login shell

```bash
chsh -s /run/current-system/sw/bin/fish
```

Log out and back in (or open a new login terminal), then `fish --version`.

### 10. Homebrew bundle and runtimes

```bash
cd ~/.config/nix
brew bundle install
xcode-select --install   # if needed
asdf plugin add python
asdf plugin add nodejs
asdf plugin update python
```

Personal: comment Kraken-only lines in `Brewfile`. Python build issues:
[One-shot Homebrew](#one-shot-homebrew-brewfile).

Work machine with kraken-core:

```bash
cd ~/Projects/kraken-core
inv install-system-deps
```

### If something fails

- **`nix build` — attribute does not exist:** fix the host key in `machines.nix` or set
  `NIXHOST` to that exact string.
- **`ssh -T` — Permission denied:** key not on GitHub yet, or wrong GitHub account.
- **Unexpected files in `/etc`:** back up `/etc/nix/nix.conf`, `/etc/bashrc`,
  `/etc/zshrc`, re-add flakes to `/etc/nix/nix.conf`, retry step 8.
- **`com.apple.universalaccess`:** set Zoom in **System Settings → Accessibility** (not
  managed by Nix on all macOS versions).

Then continue with [After install](#after-install-system-settings-and-apps).

## After install: System Settings and apps

Do these once the system has switched; they are not fully declarative in this flake.

- **Accessibility → Zoom:** enable **Use scroll gesture with modifier keys to zoom**
  (Control + scroll). macOS often blocks `defaults write com.apple.universalaccess`, so
  this is not set from Nix here.
- **Raycast vs Spotlight:** set Raycast hotkey (e.g. Cmd+Space), then **Keyboard →
  Keyboard Shortcuts → Spotlight** so Spotlight does not steal the same shortcut.
- **Scroll direction:** classic vs natural is set in Nix
  (`NSGlobalDomain."com.apple.swipescrolldirection"` in `modules/mac.nix`); flip there
  if you prefer Natural.
- **Terminal / Cursor — jump by word:** Mac **Alt** is **Option**. Cursor: Option+arrows
  usually move by word. Terminal.app: **Use Option as Meta key** under the profile’s
  Keyboard settings.
- **Fish history on a new Mac:** copy `fish_history` from the old machine into
  `~/.local/share/fish/fish_history` (not tracked by this repo).

**GUI installs** (Dock pins expect these apps — most are in `Brewfile`):

| App            | Install                                                                        |
| -------------- | ------------------------------------------------------------------------------ |
| Arc            | `brew install --cask arc`                                                      |
| Cursor         | [cursor.com](https://cursor.com) or `brew install --cask cursor`               |
| Warp           | `brew install --cask warp` (also via Nix)                                      |
| Fork           | [git-fork.com](https://git-fork.com) (not in core Homebrew)                    |
| Postgres.app   | `brew install --cask postgres-unofficial`                                      |
| 1Password      | `brew install --cask 1password`                                                |
| Slack          | `brew install --cask slack`                                                    |
| Docker Desktop | `brew install --cask docker` — open Docker.app once                            |
| AeroSpace      | `brew install --cask nikitabobko/tap/aerospace`                                |
| Raycast        | Rebuild Nix (includes `raycast`) or `brew install --cask raycast` — one source |

Optional: `cd ~/.config/nix && pre-commit install`.

---

## Manual setup detail

Nix does not manage Homebrew casks, most GUI apps, or kraken’s invoke-installed brew
packages.

### Fonts

Nix installs nerd-fonts under `/Library/Fonts/Nix Fonts/`. **Fira Code Two iScript**
(Cursor’s preferred editor font) is not in that set — copy `FiraCodeTwoiScript-*.ttf`
into `~/Library/Fonts/` from another machine, or use Brewfile `font-fira-code` as a
fallback.

### Docker

Install **Docker Desktop** (`brew install --cask docker`); Nix supplies CLI tools only.

### One-shot Homebrew (`Brewfile`)

```bash
cd ~/.config/nix
brew bundle install
```

Comment out Kraken or GUI lines you do not need.

If **`asdf install python`** finishes but stdlib pieces are missing (`sqlite3`, `_bz2`,
`_ctypes`, etc.), install Brewfile libs, then **rebuild Python** with compiler flags so
`python-build` sees Homebrew headers and libraries:

```bash
cd ~/.config/nix
brew bundle install
P="$(brew --prefix)"
export LDFLAGS="-L${P}/opt/zlib/lib -L${P}/opt/bzip2/lib -L${P}/opt/readline/lib -L${P}/opt/sqlite/lib -L${P}/opt/libffi/lib -L${P}/opt/openssl@3/lib"
export CPPFLAGS="-I${P}/opt/zlib/include -I${P}/opt/bzip2/include -I${P}/opt/readline/include -I${P}/opt/sqlite/include -I${P}/opt/libffi/include -I${P}/opt/openssl@3/include"
export PKG_CONFIG_PATH="${P}/opt/sqlite/lib/pkgconfig:${P}/opt/zlib/lib/pkgconfig:${P}/opt/libffi/lib/pkgconfig:${P}/opt/openssl@3/lib/pkgconfig"

asdf uninstall python 3.14.6t   # exact name from: asdf list python
asdf install python 3.14.6t
```

**Fish** (same flags; `set -gx` exports for child processes such as `asdf`):

```fish
cd ~/.config/nix
brew bundle install
set P (brew --prefix)
set -gx LDFLAGS "-L$P/opt/zlib/lib -L$P/opt/bzip2/lib -L$P/opt/readline/lib -L$P/opt/sqlite/lib -L$P/opt/libffi/lib -L$P/opt/openssl@3/lib"
set -gx CPPFLAGS "-I$P/opt/zlib/include -I$P/opt/bzip2/include -I$P/opt/readline/include -I$P/opt/sqlite/include -I$P/opt/libffi/include -I$P/opt/openssl@3/include"
set -gx PKG_CONFIG_PATH "$P/opt/sqlite/lib/pkgconfig:$P/opt/zlib/lib/pkgconfig:$P/opt/libffi/lib/pkgconfig:$P/opt/openssl@3/lib/pkgconfig"

asdf uninstall python 3.14.6t   # exact name from: asdf list python
asdf install python 3.14.6t
```

Use the exact version strings from `asdf list python` (for example `3.13.x` vs
`3.14.6t`). Prefer a stable **3.13.x** unless you need free-threading 3.14.

### Cursor extensions (work)

```bash
for ext in charliermarsh.ruff ms-python.python ms-python.debugpy \
  ms-python.vscode-pylance esbenp.prettier-vscode rioj7.command-variable; do
  cursor --install-extension "$ext"
done
```

Workspace-specific settings stay in `kraken-core`’s `my.code-workspace`.

### Updating flakes

```bash
cd ~/.config/nix
nix flake update
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

**Fish:**

```fish
cd ~/.config/nix
set -gx NIXHOST (scutil --get LocalHostName)
nix flake update
sudo darwin-rebuild switch --flake ".#$NIXHOST"
```

---

## Day-to-day

```bash
cd ~/.config/nix
export NIXHOST="$(scutil --get LocalHostName)"   # or your fixed machines.nix key
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

**Fish:**

```fish
cd ~/.config/nix
set -gx NIXHOST (scutil --get LocalHostName)   # or: set -gx NIXHOST "Your-machines.nix-key"
sudo darwin-rebuild switch --flake ".#$NIXHOST"
```

Do **not** edit `~/.config/fish/config.fish` directly — it is managed by Nix. Change
sources under `modules/` and rebuild.

**What runs where:** Nix = shell, dotfiles, macOS defaults, CLI; **asdf** = Python/Node
per `.tool-versions`; **Homebrew** = casks and kraken `inv install-system-deps`
packages.

**Oh My Fish:** enabled via `modules/fish/omf.nix` (nixpkgs `oh-my-fish`). Framework is
read-only under the Nix store; install themes/packages with `omf install …` (state under
`~/.config/omf`). If nothing loads, run **`omf install default`** once. You still have
**home-manager** Fish plugins in `fish-plugins.nix` — avoid duplicating the same feature
in both places.

---

## Optional: `defaults read` and `mac.nix`

nix-darwin applies **typed options** in `system.defaults.*` by running `defaults write`
for known domains (Finder, Dock, `-g` / NSGlobalDomain, etc.). That is **not** the same
as dumping an entire plist:

- `defaults read com.apple.finder` prints **hundreds** of keys (window positions, column
  widths, iCloud state). You do **not** paste that blob into Nix.
- To align Nix with this Mac, read **single keys**, e.g.
  `defaults read -g com.apple.swipescrolldirection`, then set the matching option in
  `modules/mac.nix` **if** nix-darwin defines it.
- Browse available options under
  [nix-darwin `modules/system/defaults/`](https://github.com/LnL7/nix-darwin/tree/master/modules/system/defaults).
  Anything not modeled there can go in `system.defaults.CustomUserPreferences` as
  `"{domain}" = { Key = value; };` when `defaults write` is allowed for that domain.

---

## Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)

Never commit private keys, `.env`, or `gpg-signing-key.asc`.

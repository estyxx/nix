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
- **User:** Fish, Starship, Git (signed commits on work profile), SSH helpers
- **Window manager:** AeroSpace (`modules/aerospace.toml`)

---

## New Mac setup (follow in order)

### 1. Prerequisites

Apple Silicon or Intel Mac, admin access, terminal.

### 2. Nix + flakes (needed before `sudo nix run …`)

Install [Nix](https://nixos.org/download.html) (multi-user recommended). **Root** only
reads `/etc/nix/nix.conf` for `sudo nix`, so enable flakes there:

```bash
sudo mkdir -p /etc/nix
printf '%s\n' 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
```

You can mirror the same line in `~/.config/nix/nix.conf` for non-sudo `nix`. Restart the
terminal after installing Nix.

### 3. Homebrew (recommended)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the printed `eval "$(…/brew shellenv)"` instructions.

### 4. Clone this repo

```bash
git clone https://github.com/estyxx/nix.git ~/.config/nix
cd ~/.config/nix
```

### 5. Register this Mac in `modules/machines.nix`

The **quoted key** (left-hand side) must match what you pass to the flake as `.#Name`.

Usually it matches **Bonjour / local hostname**:

```bash
scutil --get LocalHostName
```

Add an entry (personal example):

```nix
{
  "Your-LocalHostName" = {
    username = "you.shorthost"; # must match whoami / /Users/you.shorthost
    system = "aarch64-darwin"; # or x86_64-darwin on Intel
    profile = "personal";
  };
}
```

Work (Kraken) profile: use `profile = "kraken"` and add `git.signingKey = "HEXID";` as
in existing entries in `machines.nix`.

### 6. SSH and GPG (work / signing — optional on personal)

From `~/.config/nix`:

```bash
./setup-ssh-key.sh
./setup-gpg.sh
```

**GPG secret key:** export on a machine that already has the key
(`gpg --export-secret-keys --armor KEYID > gpg-signing-key.asc`), copy the file to this
Mac (never commit it — `gpg-signing-key.asc` is gitignored), then run `./setup-gpg.sh`.
Key id in `machines.nix` is public; the `.asc` file is secret.

Add SSH public key at [GitHub → SSH keys](https://github.com/settings/keys). Test:

```bash
ssh -T git@github.com
```

### 7. Build and activate nix-darwin (copy-paste)

Run from **`~/.config/nix`**. This sets **`NIXHOST`** from macOS so you do not paste a
hostname by hand. It **must** equal the quoted key in `modules/machines.nix` (if not,
use `export NIXHOST="Exact-Key-From-machines.nix"` instead).

```bash
cd ~/.config/nix
export NIXHOST="$(scutil --get LocalHostName)"
echo "NIXHOST=$NIXHOST  (must match modules/machines.nix)"
nix build ".#darwinConfigurations.${NIXHOST}.system"
```

**First install** (until `darwin-rebuild` exists — run once):

```bash
sudo nix run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

If `sudo nix` complains flakes are disabled, use:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:LnL7/nix-darwin/master -- switch --flake ".#${NIXHOST}"
```

**Later changes:**

```bash
cd ~/.config/nix
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

**`nix build` fails “attribute … does not exist”:** add or fix the host key in
`machines.nix`, or set `NIXHOST` manually to that exact string.

**`echo NIXHOST` prints `NIXHOST`:** use `echo "$NIXHOST"` (needs `$`).

**“Unexpected files in /etc”:** rename existing `/etc/nix/nix.conf`, `/etc/bashrc`,
`/etc/zshrc` as in older docs, re-add flakes to `/etc/nix/nix.conf`, retry bootstrap.

**`Could not write domain com.apple.universalaccess`:** use a `mac.nix` revision without
`system.defaults.universalaccess`; set Zoom in **System Settings → Accessibility**.

Open a **new terminal tab** after the first switch.

### 8. Fish as login shell

```bash
chsh -s /run/current-system/sw/bin/fish
```

Log out and back in (or at least open a new login terminal), then:

```bash
fish --version
```

`gpg-test` exists only on **kraken** profile machines (`git.signingKey` in
`machines.nix`). Else test with `echo test | gpg --clearsign …`.

### 9. Homebrew bundle, runtimes, Kraken deps

```bash
cd ~/.config/nix
brew bundle install
xcode-select --install   # if you have not (headers for Python builds)
asdf plugin add python
asdf plugin add nodejs
asdf plugin update python
```

Personal Mac: edit `Brewfile` and comment Kraken-only lines you do not need. Python
build issues: see [One-shot Homebrew](#one-shot-homebrew-brewfile) below.

Work machine with kraken-core:

```bash
cd ~/Projects/kraken-core
inv install-system-deps
```

---

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

asdf uninstall python 3.14.6t   # use exact name from: asdf list python
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

---

## Day-to-day

```bash
cd ~/.config/nix
export NIXHOST="$(scutil --get LocalHostName)"   # or your fixed machines.nix key
sudo darwin-rebuild switch --flake ".#${NIXHOST}"
```

Do **not** edit `~/.config/fish/config.fish` directly — it is managed by Nix. Change
sources under `modules/` and rebuild.

**What runs where:** Nix = shell, dotfiles, macOS defaults, CLI; **asdf** = Python/Node
per `.tool-versions`; **Homebrew** = casks and kraken `inv install-system-deps`
packages.

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

---

## Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)

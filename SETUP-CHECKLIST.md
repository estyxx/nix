# New Mac setup checklist

Tick items as you go. This list matches what this flake expects (dock, Nix, Homebrew,
manual installs). Paths assume Apple Silicon Homebrew (`/opt/homebrew`).

## Nix & shell

- [ ] Nix installed with flakes (`/etc/nix/nix.conf` or `~/.config/nix/nix.conf`)
- [ ] Repo cloned to `~/.config/nix` and your hostname added to `modules/machines.nix`
- [ ] `nix build ".#darwinConfigurations.YOURHOST.system"` succeeds
- [ ] First switch:
      `sudo nix run github:LnL7/nix-darwin/master -- switch --flake ".#YOURHOST"`
- [ ] Later switches: `sudo darwin-rebuild switch --flake ".#YOURHOST"`
- [ ] Login shell is Fish: `chsh -s /run/current-system/sw/bin/fish` (then log out/in)

## Homebrew & asdf

- [ ] Homebrew installed and `eval "$(/opt/homebrew/bin/brew shellenv)"` in your profile
- [ ] `cd ~/.config/nix && brew bundle install`
- [ ] `xcode-select --install` (for compiler headers)
- [ ] `asdf plugin add python` / `asdf plugin add nodejs` and
      `asdf plugin update python`
- [ ] If Python stdlib modules fail: reinstall with `LDFLAGS` / `CPPFLAGS` from
      [README § Manual setup](./README.md#one-shot-homebrew-brewfile)

## GUI apps (Dock + common)

Dock order is set in `modules/mac.nix` (`persistent-apps`). Install missing apps:

- [ ] **Arc** — `brew install --cask arc` (or Brewfile)
- [ ] **Cursor** — cask or [cursor.com](https://cursor.com)
- [ ] **Warp** — Nix (`common-packages.nix`) and/or Brewfile; confirm it opens
- [ ] **Fork** — [git-fork.com](https://git-fork.com) (not in Brewfile)
- [ ] **Postgres.app** — `brew install --cask postgres-unofficial`
- [ ] **1Password** — `brew install --cask 1password`
- [ ] **Slack** — `brew install --cask slack`
- [ ] **Docker Desktop** — `brew install --cask docker`, then open Docker.app once
- [ ] **AeroSpace** — `brew install --cask nikitabobko/tap/aerospace`
- [ ] **Raycast** — installed via **Nix** (`raycast` in `common-packages.nix`); rebuild
      then pin to Dock if you want, or install the cask instead (pick one source only)

## Fonts & editor

- [ ] **Fira Code** (fallback) — Brewfile cask `font-fira-code`
- [ ] **Fira Code Two iScript** (Cursor first choice) — copy `FiraCodeTwoiScript-*.ttf`
      into `~/Library/Fonts/` from another machine (not on Homebrew)

## SSH, GPG, GitHub

- [ ] `./setup-ssh-key.sh` and public key added on GitHub
- [ ] `./setup-gpg.sh` (or place `gpg-signing-key.asc` and run script)
- [ ] `ssh -T git@github.com`
- [ ] **Kraken work Macs:** `gpg-test` exists in **Fish** only (needs `git.signingKey`
      in `machines.nix`). Test: `fish -c gpg-test` inside a git repo, or signed empty
      commit

## Kraken (work profile only)

- [ ] `brew bundle` Kraken formulas installed (or comment them out on personal Macs)
- [ ] `cd ~/Projects/kraken-core && inv install-system-deps`

## macOS settings worth doing by hand

Nix already sets **natural scrolling** (`modules/mac.nix`) and **Ctrl + scroll to zoom**
(`closeViewScrollWheelToggle`). After `darwin-rebuild`, confirm in **System Settings →
Mouse** and **Accessibility → Zoom**.

- [ ] **Scroll direction:** if it feels wrong, flip
      `NSGlobalDomain."com.apple.swipescrolldirection"` in `modules/mac.nix` (`true` =
      Natural, `false` = classic) and rebuild.
- [ ] **Raycast vs Spotlight:** open **Raycast** → set your preferred hotkey (e.g.
      **Cmd+Space**). Then **System Settings → Keyboard → Keyboard Shortcuts →
      Spotlight** — disable “Show Spotlight search” (or change it) so it does not fight
      Raycast.
- [ ] **Hover Text / quick highlight:** often **Accessibility → Hover Text** (hold ⌘ to
      read UI text). “Ctrl held highlights” may be Hover Text, **Increase contrast**, or
      a Raycast feature — set the one you use in System Settings.
- [ ] **Menu bar:** hide Spotlight icon if you rely on Raycast only (Control Centre /
      Spotlight settings, varies by macOS version).

## Optional dev quality-of-life

- [ ] `cd ~/.config/nix && pre-commit install`
- [ ] Cursor extensions (see README, `modules/cursor/extensions-kraken.json` on work)

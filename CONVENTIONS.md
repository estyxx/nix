# Coding conventions for this repository

## Nix

- **Formatter:** RFC-style via `nixfmt-rfc-style`. Run `nix fmt` from the repo root
  (flake defines `formatter`), or format a single file with `nix fmt path/to/file.nix`.
- **Pre-commit:** hooks run `nix fmt` on staged `.nix` files — ensure Nix is in your
  PATH.
- **Module args:** declare only what you use; end with `...` if the module ignores extra
  args. Prefer `machineConfig` for username/profile branching.
- **Imports:** system modules in `flake.nix` `modules = [ ... ]`; user modules in
  `home-manager.users.*.imports`.
- **Profile-specific config:** use `modules/machines/work.nix` or `personal.nix`,
  imported conditionally from `flake.nix` — do not hardcode usernames in shared modules.
- **Comments:** module-level header (`# modules/foo.nix — purpose`); inline trailing
  comments on packages in `common-packages.nix`.

## Fish shell

- **Source of truth:** `modules/fish/fish-functions/*.fish` — deployed by
  `fish-functions.nix` (kraken profile only).
- **Do not duplicate** function bodies in `fish-user.nix`; add or edit the `.fish` file
  and list the name in `fish-functions.nix` if new.
- **Aliases:** shared aliases in `fish-user.nix`; work-only aliases in
  `modules/machines/work.nix`.
- **Git/GPG/SSH helpers:** live in `modules/git.nix` (single `programs.fish` block).

## File placement

| Change                    | Location                             |
| ------------------------- | ------------------------------------ |
| New system package        | `modules/common-packages.nix`        |
| macOS default             | `modules/mac.nix`                    |
| AeroSpace                 | `modules/aerospace.nix`              |
| Fish plugin               | `modules/fish/fisher-plugins.nix`    |
| Starship prompt           | `modules/starship.toml`              |
| Fish function (kraken)    | `modules/fish/fish-functions/*.fish` |
| Fish alias (all machines) | `modules/fish/fish-user.nix`         |
| Fish alias (work only)    | `modules/machines/work.nix`          |
| Git / GPG / SSH           | `modules/git.nix`                    |
| New machine               | `modules/machines.nix`               |

## Markdown

- Prettier: 88 columns, `proseWrap: always` (see `.prettierrc`).
- Run `pre-commit run prettier --all-files` on markdown changes.

## Git commits

- Imperative subject, ≤70 chars; body wrapped at 72 chars (see `commit-template.txt`).
- One logical change per commit; run `pre-commit run --all-files` before pushing.

## Secrets

Never commit: private keys, tokens, `.env`, shell history, GPG secret key exports. See
`CLAUDE.md` for the full list.

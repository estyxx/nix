# Declarative Fish plugins (home-manager `programs.fish.plugins`).
# Sources: nixpkgs `fishPlugins.*` (Hydra cache, upstream bumps).
#
# | Plugin            | Upstream / role |
# |-------------------|-----------------|
# | z                 | `jethrokuan/z` — jump to frecent dirs |
# | done              | `franciscolourenco/done` — notify when long cmds finish (needs `terminal-notifier` on macOS) |
# | fzf-fish          | `PatrickF1/fzf.fish` — fzf for git / files / history (`junegunn/fzf` via Nix) |
# | forgit            | `wfxr/forgit` — interactive git on top of fzf |
# | autopair          | `jorgebucaran/autopair.fish` — insert closing `()`, `""`, etc. |
# | sponge            | `meaningful-ooo/sponge` — omit failed commands from history |
# | plugin-git        | `jhillyerd/plugin-git` — git abbreviations |
# | colored-man-pages | `patrickf3139/colored-man-pages` — colorize `man` |
#
# Other solid `fishPlugins` you can add later: `pisces` (pairs; overlaps autopair),
# `hydro` / `tide` (prompts; skip if you use Starship).
{ pkgs, ... }:
let
  fzf-fish-patched = pkgs.fishPlugins.fzf-fish.overrideAttrs (_: {
    doCheck = false;
  });

  inherit (pkgs.fishPlugins)
    z
    done
    autopair-fish
    plugin-git
    colored-man-pages
    forgit
    sponge
    ;

  mkPlugin = pkg: {
    name = pkg.pname;
    src = pkg;
  };
in
{
  programs.fish.plugins =
    [
      # Load before other fzf-dependent plugins (conf.d name sorts first).
      {
        name = "fzf-fish";
        src = fzf-fish-patched;
      }
    ]
    ++ map mkPlugin [
      z
      done
      autopair-fish
      plugin-git
      colored-man-pages
      forgit
      sponge
    ];
}

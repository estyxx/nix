# Remove legacy Fisher/Tide/Hydro files superseded by home-manager plugins.
{ lib, ... }:
{
  home.activation.cleanupLegacyFish = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    verboseEcho "Cleaning legacy Fish files (Tide, Hydro, Fisher)..."

    for stale in \
      "$HOME/.config/fish/conf.d/_tide_init.fish" \
      "$HOME/.config/fish/conf.d/hydro.fish" \
      "$HOME/.config/fish/functions/fisher.fish" \
      "$HOME/.config/fish/completions/fisher.fish" \
      "$HOME/.config/fish/fish_plugins"
    do
      if [ -e "$stale" ]; then
        verboseEcho "Removing $stale"
        $DRY_RUN_CMD rm -f "$stale"
      fi
    done

    if [ -d "$HOME/.config/fish/functions/tide" ]; then
      verboseEcho "Removing tide function directory"
      $DRY_RUN_CMD rm -rf "$HOME/.config/fish/functions/tide"
    fi

    for stale in "$HOME/.config/fish/functions/_tide"* "$HOME/.config/fish/functions/tide.fish"
    do
      if [ -e "$stale" ]; then
        verboseEcho "Removing $stale"
        $DRY_RUN_CMD rm -rf "$stale"
      fi
    done
  '';
}

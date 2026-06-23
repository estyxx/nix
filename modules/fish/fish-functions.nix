# Deploy Fish functions from ./fish-functions/ (kraken profile only).
{ lib, machineConfig, ... }:
let
  krakenFunctionSources = {
    "cless.fish" = ./fish-functions/cless.fish;
    "delete-db.fish" = ./fish-functions/delete-db.fish;
    "gcl.fish" = ./fish-functions/gcl.fish;
    "gh-commit-link.fish" = ./fish-functions/gh-commit-link.fish;
    "git-rebase-on-master.fish" = ./fish-functions/git-rebase-on-master.fish;
    "git.fish" = ./fish-functions/git.fish;
    "glom.fish" = ./fish-functions/glom.fish;
    "kraken-client.fish" = ./fish-functions/kraken-client.fish;
    "__kraken_core_dir.fish" = ./fish-functions/__kraken_core_dir.fish;
    "__kraken_core_ensure_venv.fish" = ./fish-functions/__kraken_core_ensure_venv.fish;
    "__kraken_core_is_repo.fish" = ./fish-functions/__kraken_core_is_repo.fish;
    "__kraken_core_post_pull.fish" = ./fish-functions/__kraken_core_post_pull.fish;
    "__kraken_core_requirements_changed_post_pull.fish" =
      ./fish-functions/__kraken_core_requirements_changed_post_pull.fish;
    "kraken_core_pull.fish" = ./fish-functions/kraken_core_pull.fish;
    "kraken_core_setup.fish" = ./fish-functions/kraken_core_setup.fish;
    "pri.fish" = ./fish-functions/pri.fish;
    "pt.fish" = ./fish-functions/pt.fish;
    "test_prodcat.fish" = ./fish-functions/test_prodcat.fish;
    "update_datadog_operator.fish" = ./fish-functions/update_datadog_operator.fish;
  };

  krakenFishFiles = lib.mapAttrs' (fileName: source: {
    name = ".config/fish/functions/${fileName}";
    value = { inherit source; };
  }) krakenFunctionSources;
in
{
  home.file = lib.optionalAttrs (machineConfig.profile == "kraken") krakenFishFiles;
}

# Deploy Fish functions from ./fish-functions/ (kraken profile only).
{ lib, machineConfig, ... }:
let
  krakenFunctionSources = {
    "delete-db.fish" = ./fish-functions/delete-db.fish;
    "kraken-client.fish" = ./fish-functions/kraken-client.fish;
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

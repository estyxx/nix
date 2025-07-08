# machines/personal.nix - Personal machine specific configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Machine identification
  machineInfo = {
    type = "personal";
    hostname = "Marcos-Disco-Mac-2";
    username = "esterbeltrami";
    system = "aarch64-darwin";
  };

  # Personal-specific packages
  environment.systemPackages = with pkgs; [
    # Add personal-specific packages here
  ];

  # Personal-specific homebrew casks
  homebrew.casks = [
    # Add personal-specific apps
  ];

  # Personal-specific fish functions
  programs.fish.functions = {
    # Add personal-specific functions here
  };

  # Personal-specific environment variables
  environment.variables = {
    # Add personal-specific env vars here
  };
}

{ config, pkgs, ... }:

{

  # Configure Fish as an available shell
  environment.shells = with pkgs; [
    fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.grc
    fishPlugins.autopair
    fishPlugins.tide
    fzf
    grc
  ];

  # Environment variables are set differently in nix-darwin
  # We'll set these in the main configuration
  environment.variables = {
    COMPOSE_DOCKER_CLI_BUILD = "1";
    DOCKER_BUILDKIT = "1";
    BUILDKIT_PROGRESS = "plain";
    PYTHONDONTWRITEBYTECODE = "1";
    BROWSER = "arc"; # Updated to Arc browser
    DEBUG_PRINT_LIMIT = "10000";
  };

  programs.fish = {
    enable = true;
    vendor = {
      config.enable = true;
      completions.enable = true;
      functions.enable = true;
    };

  };

  # System-wide package installations
  environment.systemPackages = with pkgs; [
    fish
  ];

}

{ config, pkgs, ... }:

{
  # Make Fish available system-wide
  environment.shells = with pkgs; [ fish ];
  environment.systemPackages = with pkgs; [
    fish
    fzf
  ];

  # Add Homebrew to system PATH
  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # Environment variables
  environment.variables = {
    COMPOSE_DOCKER_CLI_BUILD = "1";
    DOCKER_BUILDKIT = "1";
    BUILDKIT_PROGRESS = "plain";
    PYTHONDONTWRITEBYTECODE = "1";
    BROWSER = "arc";
    DEBUG_PRINT_LIMIT = "10000";
  };
}

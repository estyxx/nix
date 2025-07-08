# machines/work.nix - Work machine specific configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Machine identification
  machineInfo = {
    type = "work";
    hostname = "KT-MAC-D32YJC7C9P";
    username = "ester.beltrami";
    system = "aarch64-darwin";
  };

  environment.systemPackages = with pkgs; [
    # Add work-specific packages here
  ];

  homebrew.casks = [
    # Add other work-specific apps
  ];

  # Work-specific fish functions
  programs.fish.functions = {
    # Navigate to kraken-core project
    cdk = {
      description = "Navigate to kraken-core project";
      body = "cd ~/Projects/kraken-core";
    };

    # Work-specific development shortcuts
    pcrun = {
      description = "Run pre-commit on changed files";
      body = "SKIP=pytest pre-commit run --files (git diff --name-only master)";
    };

    t = {
      description = "Team search";
      body = "teamsearch";
    };

    tf = {
      description = "Team search with codeowners";
      body = ''teamsearch find . -c .github/CODEOWNERS -t "octoenergy/product-catalog" -p'';
    };
  };

  # Work-specific environment variables
  environment.variables = {

  };
}

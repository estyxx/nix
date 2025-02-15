{ config, pkgs, ... }:
{
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

  programs.fish.shellAliases = {
    # Development Tools
    ## Git - Version Control
    g = "git"; # Quick git access
    gs = "git status"; # Check repository status
    gp = "git push"; # Push changes

    ## Docker - Container Management
    d = "docker"; # Docker shorthand
    dc = "docker-compose"; # Docker Compose shorthand

    # System Navigation
    ## Directory Movement
    ".." = "cd .."; # Go up one level
    "..." = "cd ../.."; # Go up two levels

    ## File Listing and Management
    ll = "ls -la"; # Detailed list view
    ls = "ls -A --sd"; # Clean list with sorting

    # System Management
    ## Process Control
    kk = "kill %"; # Kill last background job

    # Configuration Management
    ## Nix Configuration
    "nix-edit" = "code ~/.config/nix/"; # Edit Nix config

    # Network Tools
    ## HTTP Status Checking
    hstat = "curl -o /dev/null --silent --head --write-out '%{http_code}\\n'"; # Get HTTP status

    # Weather Information
    ## Location-specific Weather
    wttrh = "curl wttr.in/51.495747,-0.093726"; # Weather by coordinates
    wttrl = "curl wttr.in/London"; # Weather for London

    # Fish shell
    omh = "omf";
    fr = "omf reload";
  };
}

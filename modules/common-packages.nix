{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    ## stable
    act # Run GitHub Actions locally
    asdf
    awscli
    biome
    btop # Modern system monitor with beautiful UI
    diffr # Modern Unix `diff` with syntax highlighting
    difftastic # Modern Unix `diff` that understands code structure
    docker
    docker-compose
    drill # Clean DNS lookup tool
    du-dust # Modern Unix `du` with visual tree display
    dua # Modern Unix `du` with interactive navigation
    duf # Modern Unix `df` with colors and better formatting
    entr # Modern Unix `watch` - run commands when files change
    fastfetch # System info display tool
    fd # Fast and user-friendly alternative to `find`
    ffmpeg # Swiss army knife for video/audio processing
    figurine # ASCII art text generator
    fzf
    gh # Official GitHub CLI
    git-crypt # Encrypt sensitive files in Git repos
    gnused # GNU version of sed (more features than BSD sed)
    htop
    ipmitool # Server management via IPMI
    jq # JSON processor for command line
    mc # Midnight Commander visual file manager
    postgresql
    ripgrep # Extremely fast text search tool
    terraform # Infrastructure as Code tool
    tree # Display directory structure as tree
    unzip # Extract ZIP archives
    wget # Download files from web via command line

    warp-terminal
    vscode
    raycast
    # requires nixpkgs.config.allowUnfree = true;
    vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}

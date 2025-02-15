# modules/fish-user.nix
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.5";
          sha256 = "00zxfv1jns3001p2jhrk41vqcsd35xab8mf63fl5xg087hr0nbsl";
        };
      }
      {
        name = "fish-nvm";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fish-nvm";
          rev = "HEAD"; # Replace with specific version
          sha256 = "sha256-BNnoP9gLQuZQt/0SOOsZaYOexNN2K7PKWT/paS0BJJY"; # Add SHA after getting it
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "patrickf3139";
          repo = "fzf.fish";
          rev = "HEAD"; # Replace with specific version
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM"; # Add SHA after getting it
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "2.7.0";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];

    interactiveShellInit = ''
      # Prevent fisher from running updates on shell start
      set -g fisher_path $HOME/.config/fish/fisher

      # Only initialize fisher if it's not already initialized
      if not functions -q fisher && test -f $fisher_path/functions/fisher.fish
        source $fisher_path/functions/fisher.fish
      end
    '';

    shellInit = ''
      set -gx PATH $HOME/.nix-profile/bin $PATH
      set -g fish_greeting "Welcome to your Nix-managed Fish shell!"
    '';

    shellAliases = {
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
  };
}

{
  description = "Minimal MacOS Setup with Fish Shell";

  # Define where Nix should look for inputs
  inputs = {
    # nixpkgs-unstable for the latest package versions
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager for managing user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin for MacOS-specific settings
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Define the configuration for your system
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
    }:
    let
      username = "esterbeltrami";
      hostname = "Marcos-Disco-Mac-2";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Basic Darwin configuration
          (
            { pkgs, ... }:
            {
              # Add this line to fix the GID mismatch
              # This tells nix-darwin to use the correct GID that matches your system's actual Nix installation.
              ids.gids.nixbld = 350;

              system.stateVersion = 4;
              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Set system-level user configuration
              users.users.${username} = {
                name = username;
                home = "/Users/${username}";
                shell = "${pkgs.fish}/bin/fish";
              };

              # List packages installed in system profile
              environment.systemPackages = with pkgs; [
                fish
              ];

              # Set Fish as a login shell
              environment.shells = with pkgs; [ fish ];
              programs.fish.enable = true;
            }
          )

          # Home Manager configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          # Add this line to enable automatic backups
          home-manager.backupFileExtension = "backup";
            home-manager.users.${username} =
              { pkgs, ... }:
              {
                home.homeDirectory = "/Users/${username}"; # Change this to your actual username
                home.stateVersion = "23.11";

                programs.fish = {
                  enable = true;

                  # Basic Fish configuration
                  shellInit = ''
                    # Set environment variables
                    set -gx PATH $HOME/.nix-profile/bin $PATH
                  '';

                  # Add a simple alias as a test
                  shellAliases = {
                    "nix-edit" = "code ~/.config/nix/"; # Adjust if using a different editor
                  };
                };
              };
          }
        ];
      };
    };
}

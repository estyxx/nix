{
  description = "Minimal MacOS Setup with Fish Shell";

  # External dependencies required for our system configuration
  inputs = {
    # The main Nix package collection, using the unstable branch for latest versions
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager manages user-specific configurations
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin provides macOS-specific configuration options
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
    }:

    let
      myModules = {
        fish = import ./modules/fish/fish.nix;
        fishUser = import ./modules/fish/fish-user.nix;
        machines = import ./modules/machines.nix;
        git = import ./modules/git.nix;
      };

      # Function to create a Darwin system configuration for each machine
      mkDarwinSystem =
        name: machine:
        darwin.lib.darwinSystem {
          # Specify the system architecture (e.g., aarch64-darwin for Apple Silicon)
          system = machine.system;

          modules = [
            # Include custom aliases
            myModules.fish

            # Basic Darwin configuration
            (
              { pkgs, ... }:
              {
                ids.gids.nixbld = 350; # Fix GID mismatch
                system.stateVersion = 4;
                nixpkgs.config.allowUnfree = true;

                # Configure the user account
                users.users.${machine.username} = {
                  name = machine.username;
                  home = "/Users/${machine.username}";
                  shell = "${pkgs.fish}/bin/fish";
                };

              }
            )

            # Home Manager configuration
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              # User-specific configuration
              home-manager.users.${machine.username} =
                { pkgs, ... }:
                {
                  home.homeDirectory = "/Users/${machine.username}";
                  home.stateVersion = "23.11";
                  imports = [
                    myModules.fishUser
                    myModules.git
                  ];

                };
            }
          ];
        };
    in
    {
      # Create configurations for all machines defined in machines.nix
      # This automatically generates a configuration for each machine
      darwinConfigurations = builtins.mapAttrs mkDarwinSystem myModules.machines;
    };
}

{
  description = "Minimal MacOS Setup with Fish Shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    let
      myModules = {
        fish = import ./modules/fish/fish.nix;
        fishUser = import ./modules/fish/fish-user.nix;
        fishFunctions = import ./modules/fish/fish-functions.nix;
        machines = import ./modules/machines.nix;
        machinesWork = import ./modules/machines/work.nix;
        machinesPersonal = import ./modules/machines/personal.nix;
        git = import ./modules/git.nix;
        mac = import ./modules/mac.nix;
        commonPackages = import ./modules/common-packages.nix;
        fisherPlugins = import ./modules/fish/fisher-plugins.nix;
        aerospace = import ./modules/aerospace.nix;
        starship = import ./modules/starship.nix;
      };

      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      mkDarwinSystem =
        name: machine:
        darwin.lib.darwinSystem {
          system = machine.system;

          modules = [
            myModules.fish
            myModules.mac
            myModules.commonPackages

            (
              { pkgs, ... }:
              {
                ids.gids.nixbld = 350;
                system.stateVersion = 4;
                system.primaryUser = machine.username;
                nixpkgs.config.allowUnfree = true;

                users.users.${machine.username} = {
                  name = machine.username;
                  home = "/Users/${machine.username}";
                  shell = "${pkgs.fish}/bin/fish";
                };
              }
            )

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.${machine.username} =
                { lib, ... }:
                {
                  home.homeDirectory = "/Users/${machine.username}";
                  home.stateVersion = "23.11";
                  imports =
                    [
                      myModules.fishUser
                      myModules.fishFunctions
                      myModules.fisherPlugins
                      myModules.aerospace
                      myModules.starship
                      myModules.git
                    ]
                    ++ lib.optional (machine.profile == "kraken") myModules.machinesWork
                    ++ lib.optional (machine.profile == "personal") myModules.machinesPersonal;

                  _module.args = {
                    machineConfig = machine;
                  };
                };
            }
          ];
        };
    in
    {
      darwinConfigurations = builtins.mapAttrs mkDarwinSystem myModules.machines;
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}

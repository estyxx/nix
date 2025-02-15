# My Nix Development Environment

A reproducible macOS development environment using Nix.

## Prerequisites

- macOS (tested on Apple Silicon)
- [Nix package manager](https://nixos.org/download.html)

## Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/estyxx/nix-config.git ~/.config/nix
   ```

2. Edit machine configuration in `modules/machines.nix`:

   ```nix
   {
     "Your-Machine-Name" = {
       username = "yourusername";
       system = "aarch64-darwin";  # or x86_64-darwin for Intel
     };
   }
   ```

3. Build and activate the configuration:

   ```bash
   cd ~/.config/nix
   nix build .#darwinConfigurations.Your-Machine-Name.system
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

## Acknowledgments

Built using:

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)

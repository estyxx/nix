# modules/fish-user.nix - User-specific Fish configuration
{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # User-specific initialization
    interactiveShellInit = ''
      # Welcome message
      set -g fish_greeting "Welcome to your Fish shell!"

      # fzf integration if available
      if command -v fzf >/dev/null 2>&1
        fzf --fish | source
      end

      # ASDF integration
      if test -f ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
        source ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
      end

       function __auto_activate_venv --on-variable PWD
            if set -q VIRTUAL_ENV
                deactivate
            end

            if test -f .venv/bin/activate.fish
                source .venv/bin/activate.fish
            end
        end

        __auto_activate_venv
    '';

    shellInit = ''
      # Add user Nix profile to PATH early
      set -gx PATH $HOME/.nix-profile/bin /etc/profiles/per-user/ester.beltrami/bin /run/current-system/sw/bin $PATH

    '';

    # All your aliases in one place
    shellAliases = {
      # Git shortcuts
      g = "git";
      gst = "git status";
      gp = "git push";

      # Project navigation
      cdk = "cd ~/Projects/kraken-core";

      # Development shortcuts
      pcrun = "SKIP=pytest pre-commit run --files (git diff --name-only master)";
      t = "teamsearch";
      tf = "teamsearch find . -c .github/CODEOWNERS -t \"octoenergy/product-catalog\" -p";

      # Docker
      d = "docker";
      dc = "docker-compose";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # File management
      ll = "ls -la";
      ls = "ls -A --sd";

      # System
      kk = "kill %";

      # Configuration
      "nix-edit" = "code ~/.config/nix/";

      # Weather
      wttrh = "curl wttr.in/51.495747,-0.093726";
      wttrl = "curl wttr.in/London";

      # Fish
      omh = "omf";
      fr = "omf reload";
    };

    # All your functions in one place
    functions = {
      # GPG functions
      gpg-restart = {
        description = "Restart GPG agent";
        body = ''
          gpgconf --kill gpg-agent
          gpg-agent --daemon
          echo "GPG agent restarted"
        '';
      };

      gpg-test = {
        description = "Test GPG signing functionality";
        body = ''
          echo "test" | gpg --clearsign --default-key 6D1237FE7876645B > /dev/null 2>&1
          if test $status -eq 0
              echo "✓ GPG signing test successful!"
          else
              echo "✗ GPG signing test failed"
          end
        '';
      };

      gpg-status = {
        description = "Show GPG agent status";
        body = ''
          gpg-connect-agent 'keyinfo --list' /bye
        '';
      };

      # Git with GPG
      gcs = {
        description = "Git commit with signature";
        body = ''
          git commit -S $argv
        '';
      };

      gcas = {
        description = "Git commit all with signature";
        body = ''
          git commit -a -S $argv
        '';
      };
    };
  };

}

# User-specific Fish shell configuration (aliases and shell init).
{
  config,
  pkgs,
  machineConfig,
  ...
}:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Welcome message
      set -g fish_greeting "Welcome Ester to your Fish shell!"

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

        # Initialize Homebrew environment
        if test -f /opt/homebrew/bin/brew
          eval "$(/opt/homebrew/bin/brew shellenv)"
        end

        # Initialize Starship prompt (if you're using it)
        if command -v starship > /dev/null
          starship init fish | source
        end
    '';

    shellInit = ''
      set -gx PATH $HOME/.nix-profile/bin /etc/profiles/per-user/${machineConfig.username}/bin /run/current-system/sw/bin $PATH
    '';

    shellAliases = {
      # Git shortcuts
      g = "git";
      gst = "git status";
      gp = "git push";

      # Docker
      d = "docker";
      dc = "docker-compose";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # File management
      ll = "colorls -la";
      ls = "colorls -A --sd";

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
      dlf = "djlint --reformat  --profile django --format-css --format-js  --preserve-blank-lines";
    };
  };
}

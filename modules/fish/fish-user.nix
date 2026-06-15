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
      set -g fish_greeting "Welcome Ester to your Fish shell!"

      # chruby (Homebrew)
      for file in /opt/homebrew/share/fish/vendor_functions.d/chruby*.fish
          test -f $file; and source $file
      end

      if command -v fzf >/dev/null 2>&1
        fzf --fish | source
      end

      # asdf: prefer Homebrew install, fall back to Nix
      if test -f /opt/homebrew/opt/asdf/libexec/asdf.fish
        source /opt/homebrew/opt/asdf/libexec/asdf.fish
      else if test -f ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
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

      if test -f /opt/homebrew/bin/brew
        eval "$(/opt/homebrew/bin/brew shellenv)"
      end

      if command -v starship >/dev/null
        starship init fish | source
      end
    '';

    shellInit = ''
      set -gx PATH $HOME/.nix-profile/bin /etc/profiles/per-user/${machineConfig.username}/bin /run/current-system/sw/bin $PATH
    '';

    shellAliases = {
      g = "git";
      gst = "git status";
      gp = "git push";

      d = "docker";
      dc = "docker-compose";

      ".." = "cd ..";
      "..." = "cd ../..";

      ll = "colorls -la";
      ls = "colorls -A --sd";

      kk = "kill %";

      "nix-edit" = "code ~/.config/nix/";

      wttrh = "curl wttr.in/51.5485162,-0.0101909?m";
      wttrl = "curl wttr.in/London?m";

      finv = "commandline (inv)";

      omh = "omf";
      fr = "omf reload";
      dlf = "djlint --reformat  --profile django --format-css --format-js  --preserve-blank-lines";
    };
  };
}

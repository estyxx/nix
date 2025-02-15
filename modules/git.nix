{ config, pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = "Ester Beltrami";
      userEmail = "beltrami.ester@gmail.com"; # Replace with your email

      ignores = [
        ".DS_Store"
        "*.swp"
        ".env"
        ".direnv"
        "node_modules"
        "__pycache__"
        "*.pyc"
        ".pytest_cache"
        ".venv"
        "dist"
        "build"
      ];

      extraConfig = {
        init = {
          defaultBranch = "main";
          templateDir = "${config.home.homeDirectory}/.git-template";
        };
        pull.rebase = true;
        push.autoSetupRemote = true;
        core = {
          editor = "code --wait";
          autocrlf = "input";
        };
        color.ui = true;
      };
    };
  };

  # Create the git template directory and pre-commit hook
  home.file.".git-template/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -f .pre-commit-config.yaml ]; then
        pre-commit install
      fi
    '';
  };
}

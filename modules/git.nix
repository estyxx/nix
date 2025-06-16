{ config, pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = "Ester Beltrami";
      userEmail = "beltrami.ester@gmail.com"; 

      signing = {
        key = "AF7EACF820CAEACD";
        signByDefault = true;
      };

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
        user = {
          name = "Ester Beltrami";
          email = "beltrami.ester@gmail.com";
          signingkey = "AF7EACF820CAEACD";
        };

         url."ssh://git@github.com/octoenergy/" = {
      insteadOf = "https://github.com/octoenergy/";
    };

        # Commit configuration
        commit = {
          gpgsign = true;
          template = "${config.home.homeDirectory}/.config/git/commit-template.txt";
          verbose = true;
        };


        # GPG configuration
        gpg = {
          program = "/opt/homebrew/bin/gpg";
        };
        "gpg \"ssh\"" = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };


        init = {
          defaultBranch = "main";
          templateDir = "${config.home.homeDirectory}/.git-template";
        };
  
        # Performance settings
        checkout = {
          workers = 0;
        };

        # UI settings
        column = {
          ui = "auto";
        };

        # Core settings
        core = {
          editor = "code --wait";
          excludesfile = "${config.home.homeDirectory}/.gitignore_global";
          fsmonitor = true;
          untrackedCache = true;
          autocrlf = "input";
        };

        # Sorting
        branch = {
          sort = "-committerdate";
        };
        tag = {
          sort = "version:refname";
        };

        # Diff settings
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };

        # Push/Pull/Fetch settings
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        pull = {
          rebase = true;
        };

        # Help and utilities
        help = {
          autocorrect = "prompt";
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        rebase = {
          updateRefs = true;
        };

        # Pager settings
        pager = {
          diff = false;
        };

        # Color settings
        color = {
          ui = true;
        };
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

  home.file.".config/git/commit-template.txt" = {
    text = ''
    # Capitalized, short (70 chars or less) summary
    #
    # More detailed explanatory text should be wrapped to 72 characters.
    # The blank line above is required.
    #
    # Remember:
    # 1. Use imperative mood ("Fix bug", not "Fixed bug")
    #    - The subject should complete "If merged, this commit will..."
    # 2. No period at the end of the summary line
    # 3. Make commits atomic (test suite should pass after each commit)
    # 4. Do only one thing per commit
    # 5. Separate code movement from code changes
    # 6. Keep refactoring separate from functional changes
    #
    # Explain:
    # - Why is this change needed?
    # - How does it address the issue?
    #
    # Include links to relevant tickets or resources below:
    #
    '';
  };

  # Create global gitignore file
  home.file.".gitignore_global" = {
    text = ''
      # Compiled source #
      ###################
      *.com
      *.class
      *.dll
      *.exe
      *.o
      *.so

      # Packages #
      ############
      # it's better to unpack these files and commit the raw source
      # git has its own built in compression methods
      *.7z
      *.dmg
      *.gz
      *.iso
      *.jar
      *.rar
      *.tar
      *.zip

      # OS generated files #
      ######################
      .DS_Store
      .DS_Store?
      ._*
      .Spotlight-V100
      .Trashes
      ehthumbs.db
      Thumbs.db

      # Python Stuff
      ####################
      .ropeproject*
      dist/
      build/
      *.pyc
      .idea
      .pydevproject
      *.egg-info
      .coverage
      *.egg

      # Others
      #
      tags
      scratch

      geckodriver.log
      *node_modules*
      *.env*
    '';
  };

  # Install required packages
  home.packages = with pkgs; [
    # GPG tools
    gnupg
    pinentry_mac
    # Git utilities
    git-crypt
    git-lfs
    # Pre-commit hooks
    pre-commit
    openssh
  ];

  # Fish shell GPG configuration
  programs.fish = {
    shellInit = ''
      # GPG configuration
      set -gx GPG_TTY (tty)
      set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    '';

    functions = {
      # GPG helper functions
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
    };
  };

  # Create GPG configuration directory and files
  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      # Cache passphrases for 8 hours (28800 seconds)
      default-cache-ttl 28800
      max-cache-ttl 86400
      
      # Use pinentry-mac for macOS integration
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
      
      # Enable SSH support
      enable-ssh-support
      
      # Allow loopback pinentry
      allow-loopback-pinentry
    '';
  };

  home.file.".gnupg/gpg.conf" = {
    executable = true;
    text = ''
      # Use GPG agent
      use-agent
      
      # Default key
      default-key AF7EACF820CAEACD
      
      # Stronger algorithms
      personal-digest-preferences SHA512 SHA384 SHA256
      personal-cipher-preferences AES256 AES192 AES
      personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
      
      # Disable weak algorithms
      weak-digest SHA1
      
      # Show long key IDs
      keyid-format 0xlong
      
      # Show fingerprints
      with-fingerprint
      
      # Cross-certify subkeys
      require-cross-certification
      
      # Disable banner
      no-greeting
    '';
  };

  programs.ssh = {
    enable = true;
    
    # SSH client configuration
    extraConfig = ''
      # GitHub configuration
      Host github.com
          HostName github.com
          User git
          IdentityFile ~/.ssh/id_ed25519
          AddKeysToAgent yes
          IdentitiesOnly yes

      # GitHub Enterprise (if needed)
      Host github-enterprise
          HostName your-github-enterprise.com
          User git
          IdentityFile ~/.ssh/id_ed25519
          AddKeysToAgent yes
          IdentitiesOnly yes

      # Default settings for all hosts
      Host *
          AddKeysToAgent yes
          IdentitiesOnly yes
          ServerAliveInterval 60
          ServerAliveCountMax 10
          TCPKeepAlive yes
          Compression yes
    '';
  };


  # Fish shell SSH functions
  programs.fish = {
    functions = {
      # SSH key management functions
      ssh-add-key = {
        description = "Add SSH key to agent and keychain";
        body = ''
          ssh-add -K ~/.ssh/id_ed25519
          echo "SSH key added to agent and keychain"
        '';
      };

      ssh-test-github = {
        description = "Test SSH connection to GitHub";
        body = ''
          echo "Testing SSH connection to GitHub..."
          ssh -T git@github.com
        '';
      };

      ssh-list-keys = {
        description = "List SSH keys in agent";
        body = ''
          ssh-add -l
        '';
      };


      ssh-key-fingerprint = {
        description = "Show SSH key fingerprint";
        body = ''
          ssh-keygen -lf ~/.ssh/id_ed25519.pub
        '';
      };
    };
  };

}

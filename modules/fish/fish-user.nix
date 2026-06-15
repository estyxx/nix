# modules/fish-user.nix - User-specific Fish configuration
{
  config,
  pkgs,
  machineConfig,
  ...
}:

{
  programs.fish = {
    enable = true;

    # User-specific initialization
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
      # Add user Nix profile to PATH early
      set -gx PATH $HOME/.nix-profile/bin /etc/profiles/per-user/${machineConfig.username}/bin /run/current-system/sw/bin $PATH
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

      pt = {
        description = "Run pytest with default django configuration";
        body = ''
          set dc_flag "--dc=CuckooGBSupportSite"  # Default data center value

          # Check args for any --dc flag and respect it if present
          set has_dc_flag 0
          # Check if any argument starts with --dc=
          for arg in $argv
              if string match -q --regex -- "^--dc=" $arg
                  set has_dc_flag 1
                  break
              end
          end

          # If no dc flag was provided in args, add the default one
          if test $has_dc_flag -eq 0
              invoke localdev.pytest $dc_flag $argv -- -vvv -s -l
          else
              invoke localdev.pytest $argv -- -vvv -s -l
          end
        '';
      };

      pri = {
        description = "Format and copy PR info to clipboard";
        body = ''
          set -l pr_info (gh pr view --json "title,url,additions,deletions")
          set -l title (echo $pr_info | jq -r '.title')
          set -l url (echo $pr_info | jq -r '.url')
          set -l additions (echo $pr_info | jq -r '.additions')
          set -l deletions (echo $pr_info | jq -r '.deletions')

          set -l formatted_output ":pr: `+$additions-$deletions` [$title]($url)"

          echo $formatted_output
          echo -n $formatted_output | pbcopy

          echo "Formatted PR info has been copied to clipboard."
        '';

      };

      test_prodcat = {
        description = "Run product catalog tests with flexible options";
        body = ''
          set -l integration false
          set -l unit false
          set -l supportsite false
          set -l create_db false
          set -l pytest_args

          # Parse arguments
          for arg in $argv
              switch $arg
                  case -i --integration
                      set integration true
                  case -u --unit
                      set unit true
                  case -s --supportsite
                      set supportsite true
                  case -c --create-db
                      set create_db true
                  case '*'
                      echo "Unknown parameter passed: $arg"
                      return 1
              end
          end

          # If no arguments were provided, assume all tests should run
          if not $integration; and not $unit; and not $supportsite
              set integration true
              set unit true
              set supportsite true
          end

          # Build the find command based on arguments
          set -l find_cmd

          if $integration
              set -a find_cmd "src/tests/integration/common"
          end
          if $unit
              set -a find_cmd "src/tests/unit"
          end
          if $supportsite
              set -a find_cmd "src/tests/functional/supportsite"
          end

          set -l db_cmd ""
          if $create_db
              set db_cmd "--create-db"
          end

          # Find directories and build pytest arguments
          if test (count $find_cmd) -gt 0
              for dir in (find $find_cmd -path '*/product_catalog' -type d)
                  set -a pytest_args "-p" "$dir/"
              end

              for dir in (find $find_cmd -path '*/contracts' -type d)
                  set -a pytest_args "-p" "$dir/"
              end

              if test (count $pytest_args) -eq 0
                  echo "No matching directories found."
              else
                  echo "Command to be executed: inv localdev.multi-pytest $pytest_args -- $db_cmd"
                  inv localdev.multi-pytest $pytest_args -- $db_cmd
              end
          else
              echo "No test categories specified."
          end
        '';
      };
    };
  };

}


function kraken_core_setup --on-variable PWD
    # Define the kraken-core project directory
    set kraken_core_dir $HOME/Projects/kraken-core

    # Check if we're in the kraken-core directory
    if test "$PWD" = "/Users/ester.beltrami/Projects/kraken-core" -o "$PWD" = "$kraken_core_dir"
        # Activate virtual environment
        source ~/.virtualenvs/kraken-core/bin/activate.fish

        # Set environment variables globally and persistently
        set -Ux KRAKEN_CLIENT CuckooGB
        set -Ux DJANGO_CONFIGURATION CuckooGBMigrations

        # Optionally set aliases for working in this project
        alias manage 'python src/manage.py'
        alias runserver 'invoke supportsite.run'

        # Override the "ggl" abbreviation to run custom command in kraken-core
        abbr -a -g ggl kraken_core_pull
        abbr -a -g gl kraken_core_pull


        # Print a message to let you know the settings have been applied
        set_color green
        echo "KRAKEN_CLIENT=$KRAKEN_CLIENT DJANGO_CONFIGURATION=$DJANGO_CONFIGURATION"
        set_color normal
    else
        # Clean up the variables if you leave the directory
        set -e KRAKEN_CLIENT
        set -e DJANGO_CONFIGURATION

        abbr -a -g gl         git pull
        abbr -a -g ggl        git pull origin \(__git.current_branch\)

    end
end

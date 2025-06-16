function kraken-client -d "Manage Kraken client and interface environment variables"
    # Display help if requested
    if test (count $argv) -gt 0; and test "$argv[1]" = help
        echo "Usage: kraken-client [CLIENT] [INTERFACE]"
        echo ""
        echo "Manages Kraken client and interface environment variables for development."
        echo ""
        echo "Options:"
        echo "  (no arguments)  Interactive client selection"
        echo "  help            Show this help message"
        echo "  list            List all available clients"
        echo "  interfaces      List all available interfaces"
        echo "  CLIENT          Set KRAKEN_CLIENT to CLIENT"
        echo "  INTERFACE       Optional: Set interface (default: Migrations)"
        echo ""
        echo "Common interfaces:"
        echo "  SupportSite         - For Django site used by support staff"
        echo "  APISite             - For Kraken GraphQL API site"
        echo "  Migrations          - For running Django migrations"
        echo "  Worker              - For running Celery Workers"
        echo "  WebhookSite         - For exposing web-hooks to third parties"
        echo "  AuthServer          - For external system authentication"
        echo "  ManagementCommand   - For running Django management commands"
        echo "  InterfaceAgnostic   - For interface-independent commands/tests"
        echo ""
        echo "Examples:"
        echo "  kraken-client                   # Interactive selection"
        echo "  kraken-client CuckooGB          # Set CuckooGB client with Migrations interface"
        echo "  kraken-client OEGB SupportSite  # Set OEGB client with SupportSite interface"
        return 0
    end

    # List interfaces if requested
    if test (count $argv) -gt 0; and test "$argv[1]" = interfaces
        echo "Available Kraken interfaces:"
        echo "- SupportSite       (Django site for support staff)"
        echo "- APISite           (GraphQL API site)"
        echo "- Migrations        (For running Django migrations)"
        echo "- DocumentationSite (User-facing documentation)"
        echo "- ManagementCommand (Django management commands)"
        echo "- WebhookSite       (Third-party service webhooks)"
        echo "- Worker            (Celery Workers)"
        echo "- AuthServer        (Identity provider)"
        echo "- InterfaceAgnostic (Interface-independent commands/tests)"
        echo ""
        echo "Additional OEGB-specific interfaces:"
        echo "- OEGBOctopusEnergySite"
        echo "- OEGBLondonPowerSite"
        return 0
    end

    # Define constants
    set -l CLIENT_FILE "./client_codes.txt"
    set -l DEFAULT_INTERFACE Migrations

    # Handle interface selection
    set -l interface $DEFAULT_INTERFACE
    if test (count $argv) -gt 1
        set interface $argv[2]
    end

    # No arguments or 'list' command: show available clients
    if test (count $argv) -eq 0; or test "$argv[1]" = list
        # Check if client file exists
        if not test -f $CLIENT_FILE
            echo "Error: $CLIENT_FILE not found in current directory."
            echo "Please specify a client manually or create the file."
            return 1
        end

        # Read client list
        set -l clients (cat $CLIENT_FILE)

        # Just list the clients if the 'list' command was used
        if test "$argv[1]" = list
            echo "Available Kraken clients:"
            printf "%s\n" $clients
            return 0
        end

        # Interactive client selection
        echo "Select a Kraken client:"
        set -l selected_number (for i in (seq (count $clients))
            echo "$i: $clients[$i]"
        end | fzf --height 40% | string match -r '^\d+' | string trim)

        # Handle client selection
        if test -n "$selected_number"
            set -l selected_client $clients[$selected_number]

            # Interactive interface selection
            echo "Select an interface (default: $DEFAULT_INTERFACE):"
            set -l interfaces Migrations SupportSite APISite Worker WebhookSite ManagementCommand DocumentationSite AuthServer InterfaceAgnostic

            # Add OEGB-specific interfaces if OEGB is selected
            if test "$selected_client" = OEGB
                set -a interfaces OEGBOctopusEnergySite OEGBLondonPowerSite
            end

            set -l selected_interface (printf "%s\n" $interfaces | fzf --height 40% --header="Press Enter to use '$DEFAULT_INTERFACE'")

            # Use default if nothing selected
            if test -z "$selected_interface"
                set selected_interface $DEFAULT_INTERFACE
            end

            _set_kraken_environment $selected_client $selected_interface
        end
    else
        # Direct client selection from argument
        _set_kraken_environment $argv[1] $interface
    end
end

# Helper function to set environment variables
function _set_kraken_environment -a client interface -d "Set Kraken environment variables"
    echo "Setting up Kraken environment for client: $client"
    set -gx KRAKEN_CLIENT $client
    set -gx DJANGO_CONFIGURATION "$client$interface"
    
    echo "✅ Environment configured:"
    echo "   KRAKEN_CLIENT=$KRAKEN_CLIENT"
    echo "   DJANGO_CONFIGURATION=$DJANGO_CONFIGURATION"
    
    # Set the command based on the interface
    set -l run_command
    switch $interface
        case "SupportSite"
            set run_command "inv supportsite.run"
        case "APISite"
            set run_command "inv apisite.run"
        case "Migrations" 
            set run_command "inv localdev.migrate-all"
    end
    
    # If a command was set, display it and insert it into terminal
    if test -n "$run_command"
        echo ""
        echo "📝 Run with:"
        echo "   $run_command"
        echo ""
        echo "   (Press Enter to execute the command)"
        
        # Insert the command into the command line buffer
        commandline $run_command
    end
end

# Tab completions for kraken-client
complete -c kraken-client -f
complete -c kraken-client -n __fish_use_subcommand -a help -d "Show help"
complete -c kraken-client -n __fish_use_subcommand -a list -d "List available clients"
complete -c kraken-client -n __fish_use_subcommand -a interfaces -d "List available interfaces"
complete -c kraken-client -n __fish_use_subcommand -a "(cat ./client_codes.txt 2>/dev/null)" -d "Set Kraken client"

# Interface completions for second argument
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a SupportSite -d "Django site for support staff"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a APISite -d "GraphQL API site"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a Migrations -d "For running Django migrations"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a DocumentationSite -d "User documentation site"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a WebhookSite -d "For webhooks to third parties"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a Worker -d "For running Celery Workers"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a AuthServer -d "For identity provider"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a ManagementCommand -d "For Django management commands"
complete -c kraken-client -n "not __fish_use_subcommand; and __fish_is_nth_token 2" -a InterfaceAgnostic -d "Interface-independent commands"

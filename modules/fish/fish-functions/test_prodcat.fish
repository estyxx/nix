function test_prodcat
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
end

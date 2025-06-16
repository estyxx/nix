function delete-db

    # Check if pattern argument is provided
    if test (count $argv) -eq 0
        echo "Usage: delete-db <pattern>"
        echo "Example: delete-db test"
        echo "Example: delete-db dev_"
        return 1
    end
    
    set PATTERN $argv[1]
    set DATABASES (/Applications/Postgres.app/Contents/Versions/15/bin/psql -t -c "SELECT datname FROM pg_database WHERE datname LIKE '%$PATTERN%';")

    # Check if any databases were found
    if test (count $DATABASES) -eq 0
        echo "No databases found matching pattern: $PATTERN"
        return 0
    end
    
    echo "Found databases matching pattern '$PATTERN':"
    for db in $DATABASES
        set db (string trim $db)
        if test -n "$db"
            echo "  - $db"
        end
    end

    # Confirmation prompt
    echo -n "Are you sure you want to delete these databases? (y/N): "
    read -l confirm


    if test "$confirm" = "y" -o "$confirm" = "Y"
        for db in $DATABASES
            set db (string trim $db)
            if test -n "$db"
                echo "Dropping database: $db"
                /Applications/Postgres.app/Contents/Versions/15/bin/psql -c "DROP DATABASE IF EXISTS \"$db\";"
            end
        end
        echo "Database deletion complete."
    else
        echo "Operation cancelled."
    end
    I 

end

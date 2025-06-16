
function kraken_core_pull
    # Pull the current branch
    git pull origin (__git.current_branch)

    # Check if the branch is main or master, then run the extra command
    if string match -q -r '^(main|master)$' (__git.current_branch)
        inv install-python-deps
    end
end

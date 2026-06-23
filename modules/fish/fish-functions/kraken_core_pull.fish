function kraken_core_pull
    set -l branch (__git.current_branch)

    # Bypass git.fish wrapper — post_pull runs once below.
    command git pull origin $branch
    set -l pull_status $status

    if test $pull_status -eq 0
        __kraken_core_post_pull
    end

    return $pull_status
end

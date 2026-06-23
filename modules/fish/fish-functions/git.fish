# In kraken-core, run post-pull python deps sync after `git pull` (same as `gl` / `ggl`).
function git --wraps git
    if test (count $argv) -ge 1; and test "$argv[1]" = pull
        command git $argv
        set -l pull_status $status

        if test $pull_status -eq 0
            __kraken_core_post_pull
        end

        return $pull_status
    end

    command git $argv
end

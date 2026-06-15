function git-rebase-on-master
    function _run
        echo
        echo "> $argv"
        $argv
    end

    set use_latest false
    if test (count $argv) -ge 1; and test "$argv[1]" = "--latest"
        set use_latest true
        set argv $argv[2..]
    end

    if not git rev-parse --is-inside-work-tree &>/dev/null
        echo "❌ Not a git repository." >&2
        return 1
    end

    set current_branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$current_branch"
        echo "❌ Detached HEAD. Checkout a branch first." >&2
        return 1
    end

    if test "$current_branch" = "master"
        echo "❌ You are already on 'master'." >&2
        return 1
    end

    if not git diff --quiet; or not git diff --cached --quiet
        echo "❌ You have uncommitted changes. Please commit or stash them first." >&2
        return 1
    end

    if $use_latest
        echo "Using --latest: rebasing on the latest master commit"

        _run git checkout master

        set pull_output (git pull origin master 2>&1)
        set pull_status $status
        if test $pull_status -ne 0
            echo "⚠️  'git pull origin master' failed." >&2
            echo $pull_output
            return 1
        end
        echo $pull_output

        _run git checkout "$current_branch"

        if not _run git rebase master
            echo "⚠️  Rebase failed. Resolve conflicts, then run 'git rebase --continue' manually." >&2
            return 1
        end

        _run inv install-python-deps
        echo
        echo "✅ Successfully rebased '$current_branch' on top of master."

    else
        echo "Finding the latest passing commit from CircleCI..."
        echo

        set passing_commit (inv circleci.get-latest-passing-master 2>&1)
        set inv_status $status
        if test $inv_status -ne 0
            echo >&2
            echo "❌ Failed to get latest passing commit from CircleCI (see error output above)" >&2
            echo >&2
            echo "💡 Please resolve the issue or run with --latest to rebase on the most recent master commit instead:" >&2
            echo "   git-rebase-on-master --latest" >&2
            return $inv_status
        end

        echo
        echo "✓ Latest passing commit: $passing_commit"

        if not git cat-file -e "$passing_commit" 2>/dev/null
            echo "Commit not found locally. Fetching from origin..."
            _run git fetch origin master
        end

        if not _run git rebase "$passing_commit"
            echo "⚠️  Rebase failed. Resolve conflicts, then run 'git rebase --continue' manually." >&2
            return 1
        end

        echo "✓ Successfully rebased '$current_branch' on commit $passing_commit"

        echo "Installing dependencies..."
        _run inv install-python-deps
        echo
        echo "✅ Successfully rebased '$current_branch' on the latest passing master commit."
    end

    functions --erase _run
end

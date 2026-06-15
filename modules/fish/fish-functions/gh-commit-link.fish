function gh-commit-link --description "Get GitHub link for the last commit, optionally in PR context"
    set -l commit_hash
    if test (count $argv) -gt 0
        set commit_hash $argv[1]
    else
        set commit_hash (git rev-parse HEAD)
    end

    set -l pr_info (gh pr view --json number,url 2>/dev/null)
    if test $status -eq 0
        set -l pr_number (echo $pr_info | jq -r '.number')
        set -l repo_url (git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        set -l commit_url "$repo_url/pull/$pr_number/commits/$commit_hash"
        echo $commit_url

        if command -v pbcopy >/dev/null
            echo $commit_url | pbcopy
            echo "📋 Link copied to clipboard!"
        end
    else
        set -l repo_url (git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        set -l commit_url "$repo_url/commit/$commit_hash"
        echo $commit_url

        if command -v pbcopy >/dev/null
            echo $commit_url | pbcopy
            echo "📋 Link copied to clipboard!"
        end
    end
end

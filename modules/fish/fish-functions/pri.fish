function pri
    set -l pr_info (gh pr view --json "title,url,additions,deletions")
    set -l title (echo $pr_info | jq -r '.title')
    set -l url (echo $pr_info | jq -r '.url')
    set -l additions (echo $pr_info | jq -r '.additions')
    set -l deletions (echo $pr_info | jq -r '.deletions')

    set -l formatted_output ":pr: `+$additions-$deletions` [$title]($url)"
    
    echo $formatted_output
    echo -n $formatted_output | pbcopy

    echo "Formatted PR info has been copied to clipboard."
end

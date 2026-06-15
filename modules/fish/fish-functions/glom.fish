function glom
    git log --oneline --decorate --color --reverse ( __git.default_branch )..HEAD --format="- **%s**" | tee /tmp/glom_output && cat /tmp/glom_output | pbcopy
end

# Mirrors kraken-core pre-commit post-merge hook: check-if-requirements-changed.
function __kraken_core_requirements_changed_post_pull
    if not git rev-parse ORIG_HEAD &>/dev/null
        return 1
    end

    not git diff ORIG_HEAD HEAD --quiet -- requirements/*.txt
end

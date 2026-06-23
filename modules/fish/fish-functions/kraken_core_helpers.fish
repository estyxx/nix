# Shared helpers for kraken-core (pull, setup, git pull wrapper).
function __kraken_core_dir
    echo $HOME/Projects/kraken-core
end

function __kraken_core_is_repo
    set -l top (git rev-parse --show-toplevel 2>/dev/null)
    test "$top" = (__kraken_core_dir)
end

function __kraken_core_ensure_venv
    set -l kraken_core_dir (__kraken_core_dir)
    set -l venv_activate "$kraken_core_dir/.venv/bin/activate.fish"

    if not test -f $venv_activate
        echo "⚠️  No venv at $venv_activate — run inv install-python-deps first." >&2
        return 1
    end

    if set -q VIRTUAL_ENV; and test "$VIRTUAL_ENV" = "$kraken_core_dir/.venv"
        return 0
    end

    source $venv_activate
end

# Mirrors kraken-core pre-commit post-merge hook: check-if-requirements-changed.
function __kraken_core_requirements_changed_post_pull
    if not git rev-parse ORIG_HEAD &>/dev/null
        return 1
    end

    not git diff ORIG_HEAD HEAD --quiet -- requirements/*.txt
end

function __kraken_core_post_pull
    if not __kraken_core_is_repo
        return 0
    end

    if not __kraken_core_requirements_changed_post_pull
        return 0
    end

    echo -ne "\033[33mWARNING: Python requirements have been updated. Please run inv install-python-deps\033[0m\n\n"

    if not __kraken_core_ensure_venv
        return 1
    end

    inv install-python-deps
end

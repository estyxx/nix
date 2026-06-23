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

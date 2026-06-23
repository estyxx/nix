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

function __kraken_core_is_repo
    set -l top (git rev-parse --show-toplevel 2>/dev/null)
    test "$top" = (__kraken_core_dir)
end

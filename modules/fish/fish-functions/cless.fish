function cless -d "Configure less to colorize styled text using environment variables before executing a command that will use less"
    set -x LESS_TERMCAP_md (set_color --bold 0280A5)
    set -x LESS_TERMCAP_me (set_color normal)
    set -x LESS_TERMCAP_us (set_color --underline 5BA502)
    set -x LESS_TERMCAP_ue (set_color normal)
    set -x LESS_TERMCAP_so (set_color --reverse F0CB02)
    set -x LESS_TERMCAP_se (set_color normal)

    $argv
end

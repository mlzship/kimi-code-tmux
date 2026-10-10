# bash completion for kc
# 用法: source 此文件,或复制到 /etc/bash_completion.d/kc
_kc() {
    local cur sub sessions
    cur="${COMP_WORDS[COMP_CWORD]}"
    sub="${COMP_WORDS[1]}"
    sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
    if [ "$COMP_CWORD" -eq 1 ]; then
        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "upgrade restart stop kill peek ls -h --help -V --version -C -- $sessions" -- "$cur"))
        return 0
    fi
    case "$sub" in
        restart|stop|kill|peek|upgrade)
            # shellcheck disable=SC2207
            COMPREPLY=($(compgen -W "$sessions" -- "$cur")) ;;
    esac
}
complete -F _kc kc

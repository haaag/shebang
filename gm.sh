#!/usr/bin/env bash

PROG="${0##*/}"
CMD=gm
DEPS=("$CMD" dunstify xclip fzf)
declare -a CMD_ARGS=(--list --oneline --color=always)
declare -a FZF_ARGS=(--ansi --no-preview --tac --layout=default --cycle)
FZF_ARGS+=(--prompt='  Gomarks> ')

# result data
URL=""
TITLE=""

# shellcheck source=/dev/null
[[ -f "$HOME/.config/shell/fzf.sh" ]] && source "$HOME/.config/shell/fzf.sh"

function log_err {
    printf "%s: %s\n" "$PROG" "$*" >&2
    delay
    exit 1
}

function delay {
    read -p "Press ENTER to continue..." -r _
}

function copy_to_clipboard {
    local content="$1"
    $SHELL -c "echo -n '$content' | nohup xclip -selection clipboard >/dev/null 2>&1"
}

function get_bookmark {
    local bookmark retcode id
    bookmark=$("$CMD" "${CMD_ARGS[@]}" | fzf "${FZF_ARGS[@]}")
    retcode="$?"

    if [[ "$retcode" -ne 0 ]]; then
        exit "$retcode"
    fi

    id=$(echo "$bookmark" | awk '{print $1}')
    URL=$("$CMD" "$id" -F url)
    TITLE=$("$CMD" "$id" -F title)
}

function main {
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" >/dev/null; then
            log_err "dependency '$dep' not found"
        fi
    done

    get_bookmark

    setsid -f xdg-open "$URL"
    dunstify -r 696 -i "do-not-exists" "⭐ Gomarks" "$TITLE"
}

main "$@"
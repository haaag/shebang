#!/usr/bin/env bash

PROG="${0##*/}"

# shellcheck source=/dev/null
[[ -f "$HOME/.dotfiles/private/env/ntfy.sh" ]] && . "$HOME/.dotfiles/private/env/ntfy.sh"

function log_err {
    local msg="$1"
    notify-send "$PROG" "$msg"
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

if [[ -z "$VOID_TOPIC" ]]; then
    log_err "ntfy <topic> can not be empty"
fi

notify-ntfy \
    --topic="${VOID_TOPIC}" \
    --title="Finding my phone..." \
    --mesg="You found me!!!" \
    --tags="rotating_light,iphone" \
    --priority="urgent"

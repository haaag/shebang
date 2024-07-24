#!/usr/bin/env bash

PROG="${0##*/}"
TITLE="📱 Find my phone..."

# shellcheck source=/dev/null
[[ -f "$HOME/.dotfiles/private/env/pushover.sh" ]] && . "$HOME/.dotfiles/private/env/pushover.sh"

function log_err {
    local msg="$1"
    notify-send "$PROG" "$msg"
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

if [[ -z "$PUSHOVER_TOKEN" ]]; then
    log_err "push <token> can not be empty"
elif [[ -z "$PUSHOVER_USER" ]]; then
    log_err "push <user> can not be empty"
elif [[ -z "$PUSHOVER_API" ]]; then
    log_err "push api URL can not be empty"
fi

curl -s \
    -F "token=${PUSHOVER_TOKEN}" \
    -F "user=${PUSHOVER_USER}" \
    -F "title=${TITLE}" \
    -F "device=${PUSHOVER_DEVICE:-}" \
    -F "priority=1" \
    -F "retry=30" \
    -F "expire=90" \
    -F "message=Hi!" \
    "${PUSHOVER_API}" >/dev/null

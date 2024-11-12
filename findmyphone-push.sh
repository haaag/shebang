#!/usr/bin/env bash

PROG="${0##*/}"
TITLE="📱 Find my phone..."

# shellcheck source=/dev/null
[[ -f "${PRIVATE_ROOT:-}/pushover.sh" ]] && . "$PRIVATE_ROOT/pushover.sh"

function send_notification {
    local prog
    local mesg="<b>$1</b>"
    prog=$(echo "$PROG" | tr '[:lower:]' '[:upper:]')
    notify-send -i "preferences-system-notifications" "$prog" "$mesg"
}

function log_err {
    local msg="$1"
    send_notification "$msg"
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

[[ -z "$PUSHOVER_TOKEN" ]] && log_err "push <i>token</i> can not be empty"
[[ -z "$PUSHOVER_USER" ]] && log_err "push <i>user</i> can not be empty"
[[ -z "$PUSHOVER_API" ]] && log_err "push <i>api URL</i> can not be empty"

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

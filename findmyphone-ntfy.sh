#!/usr/bin/env bash

PROG="${0##*/}"

# shellcheck source=/dev/null
[[ -f "${PRIVATE_ROOT:-}/ntfy.sh" ]] && . "$PRIVATE_ROOT/ntfy.sh"

function _notifyme {
    local prog
    local mesg="<b>$1</b>"
    prog=$(echo "$PROG" | tr '[:lower:]' '[:upper:]')
    notify-send -i "preferences-system-notifications" "$prog" "$mesg"
}

function _logerr {
    local msg="$1"
    _notifyme "$msg"
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

[[ -z "$VOID_TOPIC" ]] && _logerr "ntfy <i>topic</i> can not be empty"

notify-ntfy \
    --topic="${VOID_TOPIC}" \
    --title="Finding my phone..." \
    --mesg="You found me!!!" \
    --tags="rotating_light,iphone" \
    --priority="urgent"

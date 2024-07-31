#!/usr/bin/env bash

# Simple script for adding torrents to `transmission` via magnet links.
#
# The `transmission-add` script is an external Python tool that can be used to
# add magnet links, assign labels to torrents, and move torrent files to
# different locations.

PROG=$(basename "$0")
CMD="transmission-daemon"
declare -a DEPS=(transmission-add tremc)

function logme {
    printf "%s: %s\n" "$PROG" "$*"
}

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        printf "%s: %s\n" "$PROG" "'$dep' not found" >&2
        exit 1
    fi
done

function add_transmission {
    local magnet="$1"
    local msg="torrent added"

    if ! is_running "$CMD"; then
        logme "$CMD not running"
        echo
        usage
    fi

    if [[ -z "$magnet" ]]; then
        logme "you must provide a magnet link"
        exit 1
    fi

    transmission-add "$magnet" && notify-send "$msg"
    logme "$msg"
}

function is_running {
    local cmd="$1"
    if ! pgrep -f "$cmd" &>/dev/null; then
        return 1
    fi

    return 0
}

function usage {
    cat <<-_EOF
usage: $PROG [options]

options:
    -a, add         add torrent by magnet link
    -s, start       start daemon $CMD
    -k, kill        stop daemon $CMD
    -x, tremc       run tremc
_EOF
    exit
}

function main {
    local subcommand="$1"
    local magnet="${2:-$subcommand}"

    case "$subcommand" in
    -s | start) setsid "$CMD" && logme "$CMD started" ;;
    -k | kill) pkill -f "$CMD" && logme "$CMD stopped" ;;
    -a | add) add_transmission "$magnet" ;;
    -h | help)
        shift
        usage
        ;;
    -x | tremc) tremc -X ;;
    *) tremc -X ;;
    esac
}

main "$1" "$2"

#!/usr/bin/env bash
#
# Good functions found out there
#

PROG="${0##*/}"
[[ -v debug ]] && set -x

# SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# DIR=${0%/*}
# SOURCE=${BASH_SOURCE[0]}
# PROG="${0##*/}"
# PROG="$(basename "$0")"
# with symlink
# echo "Specials: !=$!, -=$-, _=$_. ?=$?, #=$# *=$* @=$@ \$=$$ …"
#
# SIGNALS
# Disable CTRL-Z because if we allowed this key press,
# then the script would exit but, nsxiv would still be
# running
# trap "" SIGTSTP

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $(basename "$0") <new-version>"
    exit 1
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: $(basename "$0") <item>"
fi

function line {
    local w char
    w="$(tput cols)"
    char="="
    printf "%${w}s\n" | sed "s/ /$char/g"
    printf "\n"
}

function in_terminal {
    # https://stackoverflow.com/questions/911168/how-can-i-detect-if-my-shell-script-is-running-through-a-pipe
    if [[ ! -t 1 ]]; then
        return 1
    fi
    return 0
}

function err {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function error {
    echo "ERROR $*"
    exit 1
}

function log_err {
    local msg="$1"
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

function log_err_and_exit {
    printf "%s: %s\n" "$PROG" "$msg" >&2
    exit 1
}

function warning {
    echo "WARNING: $*"
}

function status {
    echo ">>> $*" >&2
}

function available {
    command -v "$1" >/dev/null
}

function dependencies {
    local dependencies=(fzf)
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" >/dev/null; then
            err_msg="'$cmd' command not found."
            notification "$PROG script" "$err_msg"
            title "$err_msg"
            exit 1
        fi
    done
}

function center_text {
    local msg="$1"
    printf "%*s\n" $(((${#msg} + COLUMNS) / 2)) "$msg"
}

function center_text_with_tput {
    local msg="$1"
    columns=$(tput cols)
    printf "%*s\n" $(((${#msg} + columns) / 2)) "$msg"
}

function notification {
    local title mesg
    title="$1"
    mesg="$2"
    notify-send "$title" "$mesg"
}

function beepme {
    speaker-test -t sine -f 1000 -l1
}

function beepmemore {
    (speaker-test -t sine -f 1000) &
    pid=$!
    sleep 0.1s
    kill -9 "$pid"
}

function delay_exit {
    printf "\033]0;\a"
    if [[ -n "${FDELAY}" ]] && [[ "${FDELAY}" -gt 0 ]]; then
        echo -e "\n"
        read -n 1 -s -r -p "Press any key to continue"
        echo -e "\n"
    fi
}

# Only in ZSH
print -P "%F{160}▓▒░ The clone has failed.%f%b"
print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b"

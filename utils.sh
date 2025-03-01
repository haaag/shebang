#!/usr/bin/env bash
#
# Good functions found out there
#

PROG="${0##*/}"
[[ -v debug ]] && set -x

# flags
# set -o allexport (set -a)  # automatically export all variables
# set -o errexit (set -e)    # exit the script if a command fails
# set -o errtrace            # allow the `-e` option to apply to functions and subshells
# set -o ignoreeof           # prevent the shell from exiting on receiving EOF (Ctrl+D)
# set -o noclobber           # prevent overwriting files with redirection
# set -o noglob              # disable pathname expansion (glob)
# set -o nounset (set -u)    # exit the script if an undefined variable is used
# set -o pipefail            # return the exit status of the last command in a pipeline that failed
# set -o posix               # enable POSIX-compliant mode for more strict behavior
# set -o vi                  # enable vi editing mode for the command line
# set -o emacs               # enable emacs editing mode for the command line (default mode)
# set -o xtrace (set -x)     # print each command before executing it (for debugging)
# set -o verbose (set -v)    # print each line of the script as it is read

# SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# DIR=${0%/*}
# SOURCE=${BASH_SOURCE[0]}
# PROG="${0##*/}"
# PROG="$(basename "$0")"
# with symlink
# echo "Specials: !=$!, -=$-, _=$_. ?=$?, #=$# *=$* @=$@ \$=$$ …"

# signals
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

function separator {
    local color="${1:-$cyan}"
    local msg="$2"
    local char="-"
    local n=${#msg}
    local reset="\033[0m"
    printf "\n%s\n" "$msg"
    printf "${color}%${n}s${reset}\n" | sed "s/ /$char/g"
    printf "\n"
}

# Checks if the script is being run in a terminal, rather than piped to another
# command.
function in_terminal {
    # https://stackoverflow.com/questions/911168/how-can-i-detect-if-my-shell-script-is-running-through-a-pipe
    if [[ ! -t 1 ]]; then
        return 1
    fi
    return 0
}

function err {
    # shellcheck disable=SC2317
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function error {
    echo "ERROR $*"
    exit 1
}

function log_err {
    printf "%s: %s\n" "$PROG" "$*" >&2
    exit 1
}

function _logme {
    printf "%s: %s\n" "$PROG" "$1"
}

function err_and_exit {
    printf "%s: %s\n" "$PROG" "$*" >&2
    exit 1
}

function err {
    printf "%s: %s\n" "$PROG" "$*" >&2
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

function notification {
    local title="$1"
    local mesg="$2"
    notify-send "$title" "$mesg"
}

# displays a desktop notification with title, icon, and message.
function _notifyme {
    local prog
    local mesg="<b>$1</b>"
    local icon="${2:-dialog-warning}"
    prog=$(echo "$PROG" | tr '[:lower:]' '[:upper:]')
    notify-send -i "$icon" "$prog" "$mesg"
}

# prompts the user for confirmation before proceeding.
function confirm {
    local answer
    echo -n "are you sure you want to continue? ${GRAY}[y/N]:${NC} "
    read -r answer

    case "$answer" in
    y | Y) return 0 ;;
    n | N) return 1 ;;
    *) return 1 ;;
    esac
}

# terminates the script with an error message and exits with non-zero status
# code.
function die {
    (($# > 0)) && err "$*"
    exit 1
}

function _chdir {
    cd "$1" || {
        echo "$1 not found"
        exit 1
    }
}

# verifies the existence of required dependencies before executing a command.
function has {
    local verbose=false
    if [[ $1 == '-v' ]]; then
        verbose=true
        shift
    fi
    for c in "$@"; do
        c="${c%% *}"
        if ! command -v "$c" &>/dev/null; then
            [[ "$verbose" == true ]] && _logerr "'$c' dependency not found"
            return 1
        fi
    done
}

# checks if the current terminal is a standard terminal (not pseudo-terminal).
function _istty {
    if [[ "$(tty)" =~ ^/dev/tty[0-9]+$ ]]; then
        return 0
    fi

    return 1
}

function spinner {
    local mesg="$1"
    local i=0
    while true; do
        printf "."
        i=$((i + 1))
        if [[ $i -gt 3 ]]; then
            i=0
            printf "\r\033[K%s" "$mesg"
        fi
        sleep 0.4
    done &

    # Start signal handling to capture Ctrl+C
    # trap 'kill $! 2>/dev/null; echo; exit' SIGINT

    # kill spinner when primary function finish
    # kill $! 2>/dev/null
}

# Checks if the target is present in the given array, returns 0 if found, 1 if
# not
function _is_available {
    local target=$1
    shift
    local arr=("$@")

    for item in "${arr[@]}"; do
        if [[ "$item" == "$target" ]]; then
            return 0
        fi
    done

    return 1
}

# executes a command in the background, discarding both stdout and stderr,
# using nohup to keep it running after logout
function detach_cmd {
    nohup "$@" >"/dev/null" 2>&1 &
}

# hide the cursor
function hide_cursor {
    printf "\033[?25l"
}

# show the cursor
function show_cursor {
    printf "\033[?25h"
}

# ONLY IN ZSH
print -P "%F{160}▓▒░ The clone has failed.%f%b"
print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b"

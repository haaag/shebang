#!/usr/bin/env bash

set -e
set -o pipefail

PROGRAM=$(basename "$0")

# Colors
red="\e[91m"
magenta="\e[35m"
nc="\e[0m"

DOTFILES="$HOME/.dotfiles"
# CONFIGS=(fontconfig greenclip.toml)
PROGRAMS=(
    autorandr
    bat
    dunst
    fd
    git
    greenclip
    lazygit
    nnn
    nvim
    picom
    pipewire
    pymarks
    rofi
    sxhkd
    sxiv
    tmux
    zathura
    xss-lock
)

err() {
    printf "${red}Error:${nc} %s\n" "$*"
}

program_exists() {
    local program="$1"

    if command -v "$program" >/dev/null; then
        return 0
    else
        err "'$program' not found"
        return 1
    fi
}

dir_exists() {
    local folder="$DOTFILES/$program"

    if [ -d "$folder" ]; then
        return 0
    else
        err "'$folder' not found"
        return 1
    fi
}

confirmation() {
    local default_value="Y"
    local program="$1"
    local input

    echo -ne "Restore ${red}$program${nc}? [Y/n] "
    read -p "" -r choice
    input=${choice:-$default_value}

    case "$input" in
    y | Y) return 0 ;;
    n | N) return 1 ;;
    *) return 1 ;;
    esac
}

restore_program() {
    local program="$1"

    if program_exists "$program" && dir_exists "$program"; then
        folder="$DOTFILES/$program"
        if confirmation "$program"; then
            cd "$DOTFILES"
            stow -v "$program"
            echo -e "$folder ${magenta}restored${nc}"
            echo
        fi
    fi
}

check_dependencies() {
    local programs="fzf stow fd"
    for program in $programs; do
        if ! program_exists "$program"; then
            err "'$program' not found"
            exit 1
        fi
    done
}

restore_array() {
    # FIX: better naming
    for program in "${PROGRAMS[@]}"; do
        restore_program "$program"
    done
}

selection() {
    # shellcheck disable=2012
    selection=$(fd . -d 1 -t d "$DOTFILES" -x basename | fzf \
        --layout=reverse-list \
        --height=45% \
        --border=sharp \
        --prompt="$PROGRAM> " \
        --pointer='→' \
        --ansi \
        --multi \
        --no-preview)

    [[ -z "$selection" ]] && exit 1

    for selected in $selection; do
        restore_program "$selected"
    done
}

usage() {
    echo
    echo "Usage: $PROGRAM <command>"
    echo
    echo "command:"
    echo " pick          Pick a program to restore"
    exit 0
}

main() {
    local arg
    arg="$1"

    check_dependencies

    case "$arg" in
    pick) selection ;;
    *) restore_array ;;
    esac
}

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    usage
fi

main "$@"

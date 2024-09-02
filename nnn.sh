#!/usr/bin/env bash

cmd="nnn"

if ! command -v "$cmd" >/dev/null; then
    printf "%s: %s\n" "${0##*/}" "'$cmd' not found" >&2
    read -p "Press ENTER to continue..." -r _
    exit 1
fi

# Hacky way
# shellcheck source=/dev/null
[[ -f "$HOME/.config/shell/nnn.sh" ]] && . "$HOME/.config/shell/nnn.sh"

$cmd -e

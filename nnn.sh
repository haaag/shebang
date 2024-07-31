#!/usr/bin/env bash

# Hacky way
# shellcheck source=/dev/null
[ -f "$HOME/.config/shell/nnn.sh" ] && . "$HOME/.config/shell/nnn.sh"

nnn -e

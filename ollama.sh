#!/usr/bin/env bash

# ┏━┓╻  ╻  ┏━┓┏┳┓┏━┓
# ┃ ┃┃  ┃  ┣━┫┃┃┃┣━┫
# ┗━┛┗━╸┗━╸╹ ╹╹ ╹╹ ╹
# start ollama server

set -euo pipefail

PROG="${0##*/}"
DEPS=(podman tmux fzf)
PODIMG=docker.io/ollama/ollama
TMUX_SESSION="ollama"

# shellcheck disable=SC2034
PODCOMPOSE="
name: podollama
services:
    ollama:
        volumes:
            - ./ollama:/root/.ollama
        ports:
            - 11434:11434
        container_name: ollama
        image: docker.io/ollama/ollama
volumes:
    ollama:
        external: true
        name: ollama
"

if [[ "${1:-}" == "stop" ]]; then
    podman stop ollama
    exit 0
fi

# colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
BOLD=$(tput bold)
RESET="$(tput sgr0)"

function _logerr {
    printf "%s: %b%s%b" "$PROG" "$RED" "$1" "$RESET"
    echo
    read -p "Press ENTER to continue..." -r _
    exit 1
}

function _has {
    local c
    local verbose=false
    if [[ $1 == '-v' ]]; then
        verbose=true
        shift
    fi
    for c in "$@"; do
        c="${c%% *}"
        if ! command -v "$c" &>/dev/null; then
            [[ "$verbose" == true ]] && _logerr "$c dependency not found"
            return 1
        fi
    done
}

function _select_model {
    local model
    local models=(llama3.2 deepseek-r1)
    model=$(printf "%s\n" "${models[@]}" | fzf --tmux --no-preview --prompt="model> ")
    [[ -z "$model" ]] && exit 1

    echo "$model"
}

function _run {
    local model="$1"
    [[ -z "$model" ]] && exit 1
    printf "ollama: running model %b%b'%s'%b\n\n" "$BOLD" "$MAGENTA" "$model" "$RESET"
    podman exec -it ollama ollama run "$model"
    tmux kill-session -t "$TMUX_SESSION"
}

function _start_server {
    local started

    if [[ -z "$XDG_RUNTIME_DIR" ]]; then
        _logerr "XDG_RUNTIME_DIR not set"
    fi

    mkdir -p "$XDG_RUNTIME_DIR/containers/networks/rootless-netns/run" >/dev/null
    podman start ollama >/dev/null
    started=$?
    if [[ "$started" -eq 0 ]]; then
        printf "%b%s%b\n\n" "$GREEN" "done" "$RESET"
    else
        _logerr "could not start ollama server"
    fi
}

function _server_running {
    if ! podman ps --format "{{.Names}}" | grep -q "ollama"; then
        opts=(yes no)
        action=$(printf "%s\n" "${opts[@]}" | fzf --tmux --no-preview --prompt="start ollama server?> ")
        if [[ ! "$action" =~ ^(y|Y|yes|Yes|"")$ ]]; then
            exit 1
        fi

        echo -n "starting server..."
        _start_server
    fi
}

_has -v "${DEPS[@]}"

# check if the image is found
if ! podman image exists "$PODIMG"; then
    _logerr "image '$PODIMG' not found"
fi

# create/attach to session
if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$TMUX_SESSION" "zsh"
    tmux send-keys -t "$TMUX_SESSION" "$(declare -f _logerr)" C-m
    tmux send-keys -t "$TMUX_SESSION" "$(declare -f _server_running)" C-m
    tmux send-keys -t "$TMUX_SESSION" "$(declare -f _start_server)" C-m
    tmux send-keys -t "$TMUX_SESSION" 'clear' C-m
    tmux send-keys -t "$TMUX_SESSION" "_server_running" C-m
    tmux send-keys -t "$TMUX_SESSION" "$(declare -f _select_model)" C-m
    tmux send-keys -t "$TMUX_SESSION" "$(declare -f _run)" C-m
    tmux send-keys -t "$TMUX_SESSION" 'clear' C-m
    # shellcheck disable=2016
    tmux send-keys -t "$TMUX_SESSION" 'model=$(_select_model)' C-m
    tmux send-keys -t "$TMUX_SESSION" 'clear' C-m
    # shellcheck disable=2016
    tmux send-keys -t "$TMUX_SESSION" '_run "$model"' C-m
fi

tmux attach-session -t "$TMUX_SESSION"

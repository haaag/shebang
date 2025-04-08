#!/usr/bin/env bash

#   ┏━┓╻  ╻  ┏━┓┏┳┓┏━┓
#   ┃ ┃┃  ┃  ┣━┫┃┃┃┣━┫
#   ┗━┛┗━╸┗━╸╹ ╹╹ ╹╹ ╹
# -- start ollama server --

set -uo pipefail

PROG="${0##*/}"
DEPS=(podman fzf)
PODIMG=docker.io/ollama/ollama
IMAGE="ollama"
TMUX_SESSION="$IMAGE"
FZFARGS=(--tmux --no-preview)

# colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
BOLD=$(tput bold)
RESET="$(tput sgr0)"

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
    echo -n "$PROG: stopping server..."
    podman stop ollama >/dev/null
    echo -e "${GREEN}done${RESET}"
    exit 0
fi

function _logerr {
    printf "%s: %b%s%b" "$PROG" "$RED" "$1" "$RESET"
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

function _exec {
    podman exec -it "$IMAGE" ollama "$@"
}

function _select_model {
    local model models
    models=$(_exec list | awk -F':' '{if (NR > 1) print $1}')
    FZFARGS+=(--prompt="model> ")
    model=$(printf "%s\n" "${models[@]}" | fzf "${FZFARGS[@]}")
    if [[ -z "$model" ]]; then
        [[ -n "${TMUX:-}" ]] && tmux kill-session -t "$TMUX_SESSION"
        return
    fi

    echo "$model"
}

function _run {
    local model="$1"
    [[ -z "$model" ]] && exit 1
    printf "ollama: running model %b%b'%s'%b\n\n" "$BOLD" "$MAGENTA" "$model" "$RESET"
    podman exec -it ollama ollama run "$model"
}

function _start_server {
    local retcode
    podman start ollama >/dev/null
    retcode=$?
    if [[ "$retcode" -eq 0 ]]; then
        printf "%b%s%b\n" "$GREEN" "done" "$RESET"
    else
        _logerr "could not start ollama server"
    fi
}

function _server_running {
    if podman ps --format "{{.Names}}" | grep -q "ollama"; then
        return
    fi

    local action
    local opts=(yes no)
    FZFARGS+=(--prompt="start ollama server?> ")
    action=$(printf "%s\n" "${opts[@]}" | fzf "${FZFARGS[@]}")
    if [[ ! "$action" =~ ^(y|Y|yes|Yes|"")$ || "$?" -gt 0 ]]; then
        [[ -n "${TMUX:-}" ]] && tmux kill-session -t "$TMUX_SESSION"
        exit 1
    fi

    echo -n "$PROG: starting server..."
    _start_server
}

function main {
    _has -v "${DEPS[@]}"

    # check if the image is found
    if ! podman image exists "$PODIMG"; then
        _logerr "image '$PODIMG' not found"
    fi

    _server_running
    local model
    model=$(_select_model)
    [[ -z "$model" ]] && {
        echo -n "$PROG: stopping server..."
        podman stop "$IMAGE" >/dev/null
        echo -e "${GREEN}done${RESET}"
        exit 1
    }
    if [[ -n "${TMUX:-}" ]]; then
        tmux rename-window -t "ollama" "$model"
    fi
    _run "$model"
}

main

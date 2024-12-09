#!/usr/bin/env bash

# ┏━┓╻  ╻  ┏━┓┏┳┓┏━┓
# ┃ ┃┃  ┃  ┣━┫┃┃┃┣━┫
# ┗━┛┗━╸┗━╸╹ ╹╹ ╹╹ ╹
# start ollama server

PROG="${0##*/}"
DEPS=(podman)
PODIMG=docker.io/ollama/ollama

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

# colors
GRAY=$(tput setaf 8)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET="$(tput sgr0)"

set -euo pipefail

function _logerr {
    printf "%s: %b%s%b" "$PROG" "$RED" "$1" "$RESET"
    echo
    read -p "Press ENTER to continue..." -r _
    exit 1
}

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" >/dev/null; then
        _logerr "'$dep' dependency not found"
    fi
done

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

if ! podman image exists "$PODIMG"; then
    _logerr "image '$PODIMG' not found"
fi

if ! podman ps --format "{{.Names}}" | grep -q "ollama"; then
    echo -n "> start ollama server? ${GRAY}[n/Y]:${RESET} "
    read -r _start
    if [[ ! "$_start" =~ ^(y|Y|yes|Yes|"")$ ]]; then
        exit 1
    fi

    echo -n "starting server..."
    _start_server
fi

podman exec -it ollama ollama run llama3.2

#!/usr/bin/env bash

# Good functions found out there

[[ -v debug ]] && set -x

status() { echo ">>> $*" >&2; }

error() {
	echo "ERROR $*"
	exit 1
}

warning() { echo "WARNING: $*"; }

available() { command -v "$1" >/dev/null; }

dependencies() {
	local program
	program=$(basename "$0")
	dependencies=(fzf)
	for cmd in "${dependencies[@]}"; do
		if ! command -v "$cmd" >/dev/null; then
			err_msg="'$cmd' command not found."
			notification "$program script" "$err_msg"
			title "$err_msg"
			exit 1
		fi
	done
}

notification() {
	local title mesg
	title="$1"
	mesg="$2"
	notify-send "$title" "$mesg"
}

# Only in ZSH
print -P "%F{160}▓▒░ The clone has failed.%f%b"
print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b"

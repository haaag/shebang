#!/usr/bin/env bash

set -e
set -o pipefail

[[ -v debug ]] && set -x

PROGRAM=$(basename "$0")
DOTFILES="$HOME/.dotfiles"
PROGRAMS=(pipewire dunst sxhkd picom autorandr greenclip pymarks)

# Colors
red="\e[91m"
cyan="\e[36m"
magenta="\e[35m"
nc="\e[0m"

err() {
	printf "${red}Error:${nc} %s\n" "$*"
}

program_exists() {
	local program
	program="$1"

	if command -v "$program" >/dev/null; then
		return 0
	else
		return 1
	fi
}

dir_exists() {
	local folder
	folder="$DOTFILES/$program"

	if [ -d "$folder" ]; then
		return 0
	else
		err "'$folder' not found"
		return 1
	fi

}

restore() {
	local program
	program="$1"

	if program_exists "$program" && dir_exists "$program"; then
		folder="$DOTFILES/$program"
		echo -e "Restoring ${cyan}$program${nc}..."
		echo -e "$folder ${magenta}restored${nc}"
		read -p "Press ENTER to continue..." -r _
		cd "$DOTFILES"
		stow -v "$program"
		echo -e "$folder ${magenta}restored${nc}"
		echo ""
	fi
}

dependencies() {
	local programs
	programs="fzf stow"
	for program in $programs; do
		if ! program_exists "$program"; then
			err "'$program' not found"
			exit 1
		fi
	done
}

main() {
	for program in "${PROGRAMS[@]}"; do
		restore "$program"
	done
}

selection() {

	# shellcheck disable=2012
	# selection=$(ls "$DOTFILES" | fzf \
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
		restore "$selected"
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

dependencies
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
	usage
fi

case "$1" in
pick)
	selection
	;;
*) main ;;
esac

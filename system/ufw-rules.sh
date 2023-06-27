#!/usr/bin/env bash
# UFW Rules
# Various functions and variables are defined to configure UFW rules for different services.
# The script prompts the user for confirmation and applies the specified rules.
# Work in progress: The script currently displays the rules that would be applied but doesn't execute them.

set -e

NET="192.168.1.0/16"
NET_ADDR=("$NET")

declare -a RULES

# Colors for output formatting
red='\033[0;31m'
green="\e[1;32m"
blue="\e[1;34m"
white="\e[30;47m"
lavender="\e[30;44m"
cyan="\e[30;46m"
nc="\e[0m"

long_line() {
	w="$(tput cols)"
	char="-"
	printf "%${w}s\n" | sed "s/ /$char/g"
	printf "\n"
}

short_line() {
	w="25"
	printf "%${w}s\n" | sed "s/ /-/g"
	printf "\n"
}

# mdate() {
# 	printf "\n"
# 	echo -e "$lavender ""$(date +%H:%M) $nc $white ""$(date "+%A, %d %B %Y") $nc $white $(hostname) $nc "
# 	printf "\n"
# }

show_info() {
	printf "\n"
	echo -e "${lavender}$(date +%H:%M)${nc} ${white}$(date "+%A, %d %B %Y")${nc} ${white}$(hostname)${nc}\n"
	echo -e "${lavender} UFW Rules $nc" "${cyan} Network ${NET_ADDR[*]} $nc "
	printf "\n"
	long_line
}

# show_info() {
# 	mdate
# 	echo -e "${lavender} UFW Rules $nc" "${cyan} Network ${NET_ADDR[*]} $nc "
# 	echo ""
# 	long_line
# }

confirmation() {
	local service="$1"
	local default_value="Y"
	local message="$2"
	local input

	read -p "$message" -r choice

	input=${choice:-$default_value}

	case "$input" in
	y | Y) echo 0 ;;
	n | N) echo 1 ;;
	*) echo 1 ;;
	esac
}

# add_ufw_rule() {
#   local service="$1"
#   local rule="$2"
#
#   echo -e "Rule:\n '$rule'"
#
#   local -r input=$(confirmation "> Add rule for $service?")
#
#   if [[ "$input" -eq 0 ]]; then
#     echo -e " + ${green}Added${nc}\n"
#     RULES+=("$rule")
#   else
#     echo -e " - ${blue}Skipped${nc}\n"
#   fi
#
#   short_line
# }

add_ufw_rule() {
	local service=$1
	local rule=$2

	echo -e "Rule:\n '$rule'\n"

	local -r input=$(confirmation "$service" "> Add rule for $service? [Y/n]: ")

	if [[ "$input" -eq 0 ]]; then
		echo -e " + ${green}Added${nc}\n"
		RULES+=("$rule")
	else
		echo -e " - ${blue}Skipped${nc}\n"
	fi
	short_line
}

mmm_rules() {
	# ufw disable
	# ufw --force reset

	for i in "${NET_ADDR[@]}"; do echo "ufw allow from $i to any app 'SSH'"; done
	for i in "${NET_ADDR[@]}"; do echo "ufw allow from $i to any app 'WWW Full'"; done

	# ufw limit ssh/tcp

	# mpd
	# ufw allow in proto tcp from "$NET" to any port 6600

	# ufw logging low
	# ufw enable
}

mpd_rules() {
	local service="mpd"
	echo -e "${cyan}Service ${service}${nc}\n"
	add_ufw_rule "$service" "ufw allow in proto tcp from $NET to any port 6600 comment mpd"
}

emby_rules() {
	local service="emby"
	echo -e "${cyan}Service ${service}${nc}\n"

	add_ufw_rule "$service" "ufw allow in proto udp from $NET to any port 1900 comment emby-upnp"
	add_ufw_rule "$service" "ufw allow in proto udp from $NET to any port 1901 comment emby-upnp"
	add_ufw_rule "$service" "ufw allow in proto udp from $NET to any port 8096 comment emby"
	add_ufw_rule "$service" "ufw allow in proto udp from $NET to any port 8920 comment emby"
}

rules_detail() {
	echo -e "${cyan}Rules to apply${nc}\n"
	for i in "${RULES[@]}"; do echo "+ $i"; done
	echo ""
}

apply_rules() {
	echo ""
	for i in "${RULES[@]}"; do
		echo -e "${blue}appling rule:\n ${nc} $i"
		# sudo "$i"
	done
}

apply_all_confirmation() {
	echo ""
}

rules() {
	mpd_rules
	emby_rules
}

main() {
	show_info

	# ufw
	# ufw disable
	# ufw --force reset
	# ufw limit ssh/tcp
	# ufw logging low
	# ufw enable

	rules

	rules_detail

	local -r continue=$(confirmation "" "> Apply rules? [Y/n]: ")
	if [[ "$continue" -eq 0 ]]; then
		apply_rules
	else
		echo -e "\n${red}Exiting...${nc}"
	fi

	echo ""
	echo "WIP ufw" && exit 1
}

main

#!/usr/bin/env bash

# Extracts the YouTube channel ID from a given URL and displays it
# I use this simple script for `newsboat` and news feeds.

prog=$(basename "$0")
deps=(rg wget)

err_and_exit() {
	local msg="$1"
	printf "%s: %s" "$prog" "$msg"
	exit 1
}

[[ -z "$1" ]] && err_and_exit "no yt-channel url found"

for dep in "${deps[@]}"; do
	if ! command -v "$dep" >/dev/null; then
		err_and_exit "dependency '$dep' not found"
	fi
done

channel_id=$(wget -qO- "$1" | rg -oP 'href="https://www\.youtube\.com/feeds/videos\.xml\?channel_id=\K[^"]+')

if [[ -z "$channel_id" ]]; then
	err_and_exit "no channel ID found in the provided URL"
fi

channel_url="https://www.youtube.com/feeds/videos.xml?channel_id=$channel_id"
printf "%s\n" "$channel_url"

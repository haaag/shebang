#!/usr/bin/env bash

# Extracts the YouTube channel ID from a given URL and displays it
# I use this simple script for `newsboat` and news feeds.

[[ -z "$1" ]] && echo "err: no yt-channel url found" && exit

channel_id=$(wget -qO- "$1" | rg -oP 'href="https://www\.youtube\.com/feeds/videos\.xml\?channel_id=\K[^"]+')

if [[ -z "$channel_id" ]]; then
    echo "err: no channel ID found in the provided URL"
    exit 1
fi

channel_url="https://www.youtube.com/feeds/videos.xml?channel_id=$channel_id"
echo "$channel_url"

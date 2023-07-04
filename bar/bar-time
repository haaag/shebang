#!/bin/sh

# Output: [ICON 16:12]

icon=""
dwm_time=$(date "+%H:%M")

dwm_time() {
	printf "%s" "$SEP1"
	printf "%s %s" "$icon" "$dwm_time"
	printf "%s\n " "$SEP2"
}

dwm_time_color() {
	blue_color="^c#83a598^"
	reset_color="^d^"
	printf "%s" "$SEP1"
	printf "%s%s %s %s" "$blue_color" "$icon" "$reset_color" "$dwm_time"
	printf "%s\n" "$SEP2"
}

if [ "$DWM_COLOR" = true ]; then
	dwm_time_color
else
	dwm_time
fi

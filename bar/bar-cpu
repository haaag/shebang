#!/bin/sh

# Output: [ICON  10%]

icon=""
icon=""
cyan_color="^c#4abaaf^"
reset_color="^d^"

dwm_cpu_old() {
	cpu=$(top -bn1 | grep Cpu | awk '{print $2}')
	printf "%s" "$SEP1"
	printf "%s  %s%%" "$icon" "$cpu"
	printf "%s\n" "$SEP2"
}

dwm_cpu_color() {
	cpu=$(top -bn1 | grep Cpu | awk '{print $2}')
	printf "%s" "$SEP1"
	printf "%s%s%s  %s%%" "$cyan_color" "$icon" "$reset_color" "$cpu"
	printf "%s\n" "$SEP2"
}

cpu_no_color() {
	read -r cpu a b c previdle rest </proc/stat
	prevtotal=$((a + b + c + previdle))
	sleep 0.5
	read -r cpu a b c idle rest </proc/stat
	total=$((a + b + c + idle))
	cpu=$((100 * ((total - prevtotal) - (idle - previdle)) / (total - prevtotal)))
	echo  "$cpu"%
}

dwm_cpu() {
	read -r cpu a b c previdle rest </proc/stat
	prevtotal=$((a + b + c + previdle))
	sleep 0.5
	read -r cpu a b c idle rest </proc/stat
	total=$((a + b + c + idle))
	cpu=$((100 * ((total - prevtotal) - (idle - previdle)) / (total - prevtotal)))
	printf "%s" "$SEP1"
	printf "%s  %s%%" "$icon" "$cpu"
	printf "%s" "$SEP2"
}

if [ "$DWM_COLOR" = true ]; then
	dwm_cpu_color
else
	dwm_cpu
fi

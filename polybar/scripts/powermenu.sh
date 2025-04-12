#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

dir="~/.config/polybar/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $dir/powermenu.rasi"

# Options
shutdown=" Shutdown"
reboot=" Restart"
lock=" Lock"
suspend=" Sleep"
logout=" Logout"

yes=""
no=""

# Confirmation CMD
confirm_cmd() {
	rofi -dmenu \
		-p "Confirmation" \
		-mesg "Are you Sure?" \
		-theme "$dir/confirm.rasi"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
		ans=$(confirm_exit &)
        if [[ "$ans" == "$yes" ]]; then
			systemctl poweroff
        else
			exit
        fi
        ;;
    $reboot)
		ans=$(confirm_exit &)
        if [[ "$ans" == "$yes" ]]; then
			systemctl reboot
        else
			exit
        fi
        ;;
    $lock)
			$HOME/.config/bspwm/scripts/lock
        ;;
    $suspend)
		ans=$(confirm_exit &)
        if [[ "$ans" == "$yes" ]]; then
			mpc -q pause
			amixer set Master mute
			lock && systemctl suspend
        else
			exit
        fi
        ;;
    $logout)
		ans=$(confirm_exit &)
        if [[ "$ans" == "$yes" ]]; then
			if [[ "$DESKTOP_SESSION" == "Openbox" ]]; then
				openbox --exit
			elif [[ "$DESKTOP_SESSION" == "bspwm" ]]; then
				bspc quit
			elif [[ "$DESKTOP_SESSION" == "i3" ]]; then
				i3-msg exit
			fi
        else
			exit
        fi
        ;;
esac

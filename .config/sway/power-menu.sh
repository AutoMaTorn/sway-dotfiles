#!/bin/sh
# Power menu: fuzzel in dmenu mode. Bound to $super+Escape and the bar's power button.
choice=$(printf 'Lock\nLogout\nSuspend\nReboot\nShutdown\n' \
    | fuzzel --dmenu --prompt 'power › ' --lines 5 --width 20)

case "$choice" in
    Lock)     ~/.config/sway/lock.sh ;;
    Logout)   swaymsg exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac

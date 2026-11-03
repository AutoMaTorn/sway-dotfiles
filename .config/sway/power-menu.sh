#!/bin/sh
# Power menu: fuzzel in dmenu mode. loginctl works with systemd (Debian) and elogind (Void). Bound to $super+Escape and the bar's power button.
choice=$(printf 'Lock\nLogout\nSuspend\nReboot\nShutdown\n' \
    | fuzzel --dmenu --prompt 'power › ' --lines 5 --width 20)

case "$choice" in
    Lock)     ~/.config/sway/lock.sh ;;
    Logout)   swaymsg exit ;;
    Suspend)  loginctl suspend ;;
    Reboot)   loginctl reboot ;;
    Shutdown) loginctl poweroff ;;
esac

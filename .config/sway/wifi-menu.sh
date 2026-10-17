#!/usr/bin/env bash
# Wi-Fi dropdown on fuzzel (nmcli). Click on [wifi] in waybar.
. ~/.config/sway/menu.sh

if [ "$(nmcli radio wifi)" = disabled ]; then
    [ "$(printf 'Включить Wi-Fi\n' | menu 'wifi')" ] && nmcli radio wifi on
    exit
fi

nmcli device wifi rescan 2>/dev/null
list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list | awk -F: '
    $2 != "" && !seen[$2]++ {
        mark = ($1 == "*") ? "●" : " "
        lock = ($4 != "") ? "🔒" : " "
        printf "%s %s  %s%%  %s\n", mark, $2, $3, lock
    }')

choice=$(printf '%s\n%s\n%s\n' "$list" "Выключить Wi-Fi" "Настройки…" | grep . | menu 'wifi')
[ -z "$choice" ] && exit

case "$choice" in
    "Выключить Wi-Fi") nmcli radio wifi off; exit ;;
    "Настройки…")      exec kitty -e nmtui ;;
esac

ssid=$(sed -E 's/^. (.*)  [0-9]+%  .*$/\1/' <<<"$choice")
if grep -q '^● ' <<<"$choice"; then
    nmcli connection down id "$ssid"
elif nmcli -t -f NAME connection show | grep -qx "$ssid"; then
    nmcli connection up id "$ssid"
elif grep -q "🔒" <<<"$choice"; then
    pass=$(printf '' | menu 'пароль' --password)
    [ -n "$pass" ] && nmcli device wifi connect "$ssid" password "$pass"
else
    nmcli device wifi connect "$ssid"
fi
notify-send -a wifi "Wi-Fi" "$ssid: $(nmcli -t -f STATE general)"

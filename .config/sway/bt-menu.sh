#!/usr/bin/env bash
# Bluetooth dropdown on fuzzel (bluetoothctl). Click on [BT] in waybar.
. ~/.config/sway/menu.sh

if ! bluetoothctl show | grep -q 'Powered: yes'; then
    [ "$(printf 'Включить Bluetooth\n' | menu 'bt')" ] && { rfkill unblock bluetooth; bluetoothctl power on; }
    exit
fi

list=$(bluetoothctl devices | while read -r _ mac name; do
    if bluetoothctl info "$mac" | grep -q 'Connected: yes'; then mark="●"; else mark=" "; fi
    printf '%s %s  [%s]\n' "$mark" "$name" "$mac"
done)

choice=$(printf '%s\n%s\n%s\n%s\n' "$list" "Поиск устройств" "Выключить Bluetooth" "Настройки…" \
    | grep . | menu 'bt')
[ -z "$choice" ] && exit

case "$choice" in
    "Выключить Bluetooth") bluetoothctl power off; exit ;;
    "Настройки…")          exec kitty -e bluetui ;;
    "Поиск устройств")
        notify-send -a bluetooth "Bluetooth" "Поиск 8 с…"
        bluetoothctl --timeout 8 scan on >/dev/null
        exec "$0" ;;
esac

mac=$(sed -E 's/.*\[([0-9A-F:]{17})\]$/\1/' <<<"$choice")
name=$(sed -E 's/^. (.*)  \[.*$/\1/' <<<"$choice")
if grep -q '^● ' <<<"$choice"; then
    bluetoothctl disconnect "$mac" >/dev/null && notify-send -a bluetooth "Bluetooth" "$name отключён"
else
    bluetoothctl info "$mac" | grep -q 'Paired: yes' || bluetoothctl pair "$mac" >/dev/null
    bluetoothctl trust "$mac" >/dev/null
    bluetoothctl connect "$mac" >/dev/null && notify-send -a bluetooth "Bluetooth" "$name подключён"
fi

# Идеи

Ничего из этого пока не сделано. Текущая сессия: sway + waybar + swaync + fuzzel.

## 1. Quickshell-оболочка вместо waybar/swaync/fuzzel
Источник идеи: https://github.com/hase9awa/hyprstack-shell (Quickshell + Caelestia, GPL-3.0, только Hyprland).

- Quickshell работает на любом wlroots-композиторе, в том числе на sway.
- Сделать панель в нашем стиле: скобки `[ ]`, бело-серая палитра, скругление 14 px.
- Настоящие всплывающие панели Wi-Fi, bluetooth, звука и уведомлений вместо fuzzel и swaync.
- Столы и язык: `Quickshell.I3` вместо Hyprland-модулей (работает и с sway).
- В Debian Quickshell нет в репозитории: собирать из исходников (Qt ≥ 6.6, в trixie Qt 6.8).
- Брать у Hyprstack/Caelestia только то, что не привязано к Hyprland.
- Не переносится: режим scrolling/stacking, тайтлбары окон (модуль hyprbars), обзор окон с миниатюрами.
- План: собрать Quickshell, сделать одну панель Wi-Fi, потом переносить остальное.

## 2. Меню Wi-Fi и Bluetooth на fuzzel (откатили)
- Выпадающее меню под баром (`fuzzel --dmenu --anchor top --y-margin 54`), клик по `[wifi]` и `[BT]`.
- Wi-Fi: `nmcli device wifi list`, подключение, пароль через `--password`, выключение.
- Bluetooth: `bluetoothctl devices`, connect/disconnect, pair/trust, поиск 8 с.
- Откатили, потому что хочется настоящие панели (см. п. 1). Коммит `7526a8f` в истории.
- Скругление fuzzel (`radius=14`, рамка `4d4d4d`) откатилось вместе с ним.

## 3. Мелочи для sway
- Индикатор громкости и яркости (OSD) через уведомления swaync.
- Менеджер буфера обмена (`cliphist`, в Debian 13 может не быть).
- Правила `for_window` для `kitty -e bluetui` и `nmtui`, чтобы открывались плавающими.
- Показ батареи в баре (модуль убрали, но на ноутбуке нужен).
- Панель медиа (mpris) в центре уведомлений.

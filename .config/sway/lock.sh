#!/bin/sh
# swaylock in the automatorn palette. -f: fork, so swayidle isn't blocked.
exec swaylock -f \
    --image ~/.config/wallpapers/wallpaper.jpeg --scaling fill \
    --color 181818 \
    --inside-color 181818cc --inside-clear-color 181818cc \
    --inside-ver-color 181818cc --inside-wrong-color 181818cc \
    --ring-color 525252 --ring-ver-color d9d9d9 \
    --ring-clear-color 939393 --ring-wrong-color ffffff \
    --key-hl-color d9d9d9 --bs-hl-color 939393 \
    --line-color 00000000 --line-ver-color 00000000 \
    --line-clear-color 00000000 --line-wrong-color 00000000 \
    --separator-color 00000000 \
    --text-color EDEDED --text-ver-color EDEDED \
    --text-clear-color EDEDED --text-wrong-color EDEDED \
    --font "JetBrainsMono Nerd Font" \
    --indicator-radius 80 --indicator-thickness 6 \
    --show-failed-attempts

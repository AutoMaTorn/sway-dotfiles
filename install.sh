#!/usr/bin/env bash
# Symlink sway session configs into ~/.config.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

for d in sway waybar fuzzel mako kanshi; do
    link "$DIR/.config/$d" "$HOME/.config/$d"
done
for v in 3.0 4.0; do
    link "$DIR/.config/gtk-$v/settings.ini" "$HOME/.config/gtk-$v/settings.ini"
done
# ~/.config/xdg-desktop-portal may itself be a symlink (i3 dotfiles repo);
# link the single file so both sessions coexist.
link "$DIR/.config/xdg-desktop-portal/sway-portals.conf" \
     "$HOME/.config/xdg-desktop-portal/sway-portals.conf"

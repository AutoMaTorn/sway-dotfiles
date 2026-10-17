#!/usr/bin/env bash
# Sway session: install packages (Debian) and symlink configs into ~/.config.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v apt-get >/dev/null; then
    mapfile -t PKGS < <(sed -n '/^\[apt\]/,/^\[/p' "$DIR/packages.txt" | grep -vE '^(\[|#|$)' | tr ' ' '\n' | grep .)
    sudo apt-get update
    sudo apt-get install -y "${PKGS[@]}"

    if ! command -v brave-browser >/dev/null; then
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
            https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
            | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
        sudo apt-get update
        sudo apt-get install -y brave-browser
    fi

    if ! command -v bluetui >/dev/null; then
        cargo install bluetui
        echo 'bluetui installed to ~/.cargo/bin: add it to PATH'
    fi
fi

# Everything the sway config launches must exist
missing=()
for c in sway waybar fuzzel swaync kanshi swayidle swaylock grim slurp wl-copy \
         brightnessctl playerctl pactl lxpolkit kitty thunar brave-browser bluetui; do
    command -v "$c" >/dev/null || [ -x "$HOME/.cargo/bin/$c" ] || missing+=("$c")
done
[ ${#missing[@]} -eq 0 ] || echo "WARNING missing: ${missing[*]}"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

for d in sway waybar fuzzel swaync kanshi kitty nvim fastfetch sponux wallpapers; do
    link "$DIR/.config/$d" "$HOME/.config/$d"
done
for v in 3.0 4.0; do
    link "$DIR/.config/gtk-$v/settings.ini" "$HOME/.config/gtk-$v/settings.ini"
done
# Link the single file: ~/.config/xdg-desktop-portal stays a real directory.
link "$DIR/.config/xdg-desktop-portal/sway-portals.conf" \
     "$HOME/.config/xdg-desktop-portal/sway-portals.conf"

link "$DIR/zsh/.zshrc" "$HOME/.zshrc"

# Oh My Zsh + autosuggestions (used by zsh/.zshrc)
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        || echo "WARNING: Oh My Zsh install failed"
fi
AS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -f "$AS/zsh-autosuggestions.zsh" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AS" \
        || echo "WARNING: zsh-autosuggestions install failed"
fi

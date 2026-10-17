#!/usr/bin/env bash
# Sway session on a clean Debian 13: packages, SwayFX, fonts, own apps, zsh,
# config symlinks and a login screen. Safe to re-run: done steps are skipped.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCENEFX_VER=0.3
SWAYFX_VER=0.5.1

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1mWARNING:\033[0m %s\n' "$*" >&2; }

# Packages of one packages.txt section, one per line
pkgs() { sed -n "/^\[$1\]/,/^\[/p" "$DIR/packages.txt" | grep -vE '^(\[|#|$)' | tr ' ' '\n' | grep .; }

# Install the newest .deb of a GitHub release whose name matches a regex
gh_deb() {
    local repo="$1" re="$2" url tmp
    url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r --arg re "$re" '.assets[].browser_download_url | select(test($re))' | head -n1) || true
    [ -n "$url" ] || { warn "no .deb matching $re in $repo releases"; return 1; }
    tmp=$(mktemp -d)
    curl -fsSLo "$tmp/${url##*/}" "$url" && sudo apt-get install -y "$tmp/${url##*/}"
    local rc=$?
    rm -rf "$tmp"
    return $rc
}

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

### Preflight
[ "$(id -u)" -ne 0 ] || { echo "Run as your normal user, not root (sudo is used where needed)."; exit 1; }
command -v apt-get >/dev/null || { echo "Debian/apt only."; exit 1; }
if ! command -v sudo >/dev/null || ! sudo -v; then
    echo "sudo is not set up. As root run:  apt install sudo && usermod -aG sudo $USER"
    echo "then log out, log back in and start install.sh again."
    exit 1
fi

### Debian packages
step "apt packages"
mapfile -t PKGS < <(pkgs apt; pkgs build)
sudo apt-get update
sudo apt-get install -y "${PKGS[@]}"

### Brave
if ! command -v brave-browser >/dev/null; then
    step "Brave"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y brave-browser || warn "Brave install failed"
fi

### Own apps: sponux (launcher) and bluetui (bluetooth TUI)
step "sponux, bluetui"
dpkg -s sponux >/dev/null 2>&1 || gh_deb AutoMaTorn/sponux '/sponux_[^/]*_all\.deb$' \
    || warn "sponux install failed"
dpkg -s bluetui >/dev/null 2>&1 || gh_deb AutoMaTorn/bluetui "/bluetui_[^/]*_$(dpkg --print-architecture)\.deb$" \
    || warn "bluetui install failed"

### Telegram (flatpak, bound to $super+t)
step "Telegram"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak info org.telegram.desktop >/dev/null 2>&1 \
    || sudo flatpak install -y --noninteractive flathub org.telegram.desktop \
    || warn "Telegram install failed"

### JetBrainsMono Nerd Font (waybar, fuzzel, swaync, kitty, swaylock, agnoster prompt)
if ! fc-list : family | grep 'JetBrainsMono Nerd Font' >/dev/null; then
    step "JetBrainsMono Nerd Font"
    FONTDIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    mkdir -p "$FONTDIR"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
        | tar -xJ -C "$FONTDIR" && fc-cache -f "$FONTDIR" \
        || warn "Nerd Font install failed"
fi

### SwayFX (rounded corners): scenefx + swayfx from source into ~/.local
if ! "$HOME/.local/bin/sway" --version 2>/dev/null | grep "swayfx version $SWAYFX_VER" >/dev/null; then
    step "SwayFX $SWAYFX_VER (scenefx $SCENEFX_VER)"
    BUILD="${XDG_CACHE_HOME:-$HOME/.cache}/sway-dotfiles-build"
    rm -rf "$BUILD"
    mkdir -p "$BUILD"
    export PKG_CONFIG_PATH="$HOME/.local/lib/$(gcc -print-multiarch)/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    { git clone -q --depth 1 -b "$SCENEFX_VER" https://github.com/wlrfx/scenefx "$BUILD/scenefx" \
        && meson setup "$BUILD/scenefx/build" "$BUILD/scenefx" --prefix="$HOME/.local" -Dexamples=false \
        && ninja -C "$BUILD/scenefx/build" install \
        && git clone -q --depth 1 -b "$SWAYFX_VER" https://github.com/WillPower3309/swayfx "$BUILD/swayfx" \
        && meson setup "$BUILD/swayfx/build" "$BUILD/swayfx" --prefix="$HOME/.local" -Dsd-bus-provider=libsystemd \
        && ninja -C "$BUILD/swayfx/build" install \
        && rm -rf "$BUILD"; } \
        || warn "SwayFX build failed (log above); bin/sway-session falls back to plain sway"
fi

# Everything the sway config launches must exist
missing=()
for c in sway waybar fuzzel swaync kanshi swayidle swaylock grim slurp wl-copy \
         brightnessctl playerctl pactl lxpolkit kitty thunar brave-browser bluetui \
         sponux nmtui gsettings zsh fastfetch; do
    command -v "$c" >/dev/null || missing+=("$c")
done
[ -x "$HOME/.local/bin/sway" ] || missing+=("swayfx")
[ ${#missing[@]} -eq 0 ] || warn "missing: ${missing[*]}"

### Configs
step "config symlinks"
for d in sway waybar fuzzel swaync kanshi kitty fastfetch sponux wallpapers; do
    link "$DIR/.config/$d" "$HOME/.config/$d"
done
for v in 3.0 4.0; do
    link "$DIR/.config/gtk-$v/settings.ini" "$HOME/.config/gtk-$v/settings.ini"
done
# Link the single file: ~/.config/xdg-desktop-portal stays a real directory.
link "$DIR/.config/xdg-desktop-portal/sway-portals.conf" \
     "$HOME/.config/xdg-desktop-portal/sway-portals.conf"

link "$DIR/zsh/.zshrc" "$HOME/.zshrc"

### zsh: Oh My Zsh + autosuggestions (used by zsh/.zshrc), default shell
step "zsh"
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        || warn "Oh My Zsh install failed"
fi
AS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -f "$AS/zsh-autosuggestions.zsh" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AS" \
        || warn "zsh-autosuggestions install failed"
fi
ZSH_BIN="$(command -v zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_BIN" ]; then
    sudo chsh -s "$ZSH_BIN" "$USER"
fi

### System: groups, services, login
step "system"
sudo usermod -aG video,audio,netdev,bluetooth "$USER"
sudo systemctl enable --now NetworkManager bluetooth

# Session entry for any display manager (gdm, sddm, greetd/tuigreet...)
sudo tee /usr/share/wayland-sessions/swayfx.desktop >/dev/null <<EOF
[Desktop Entry]
Name=SwayFX
Comment=Sway with rounded corners and effects
Exec=$DIR/bin/sway-session
Type=Application
DesktopNames=sway
EOF

# Clean Debian without a desktop has no login screen: use greetd + tuigreet.
if [ ! -e /etc/systemd/system/display-manager.service ]; then
    sudo apt-get install -y greetd tuigreet
    sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 7

[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions --power-shutdown '/usr/bin/systemctl poweroff' --power-reboot '/usr/bin/systemctl reboot'"
user = "_greetd"
EOF
    sudo systemctl enable greetd
fi

step "done"
echo "Reboot, pick SwayFX on the login screen."
if grep -qsE '^\s*(auto|allow-hotplug)\s+wl' /etc/network/interfaces; then
    warn "Wi-Fi is configured in /etc/network/interfaces, so NetworkManager ignores it."
    echo "  Remove those wl* lines (keep lo), reboot, then connect with nmtui."
fi

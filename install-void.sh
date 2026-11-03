#!/usr/bin/env bash
# Sway session on a clean Void Linux (glibc): packages, fonts, own apps, zsh,
# config symlinks, runit services and a login screen. Void counterpart of
# install.sh. Safe to re-run: done steps are skipped.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1mWARNING:\033[0m %s\n' "$*" >&2; }

# Packages of one packages-void.txt section, one per line
pkgs() { sed -n "/^\[$1\]/,/^\[/p" "$DIR/packages-void.txt" | grep -vE '^(\[|#|$)' | tr ' ' '\n' | grep .; }

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

# runit: enable a service once (a symlink in /var/service)
sv_enable() {
    [ -d "/etc/sv/$1" ] || { warn "no service $1"; return 0; }
    [ -e "/var/service/$1" ] || sudo ln -s "/etc/sv/$1" /var/service/
}
sv_disable() { [ -e "/var/service/$1" ] && sudo rm "/var/service/$1" || true; }

### Preflight
[ "$(id -u)" -ne 0 ] || { echo "Run as your normal user, not root (sudo is used where needed)."; exit 1; }
command -v xbps-install >/dev/null || { echo "Void/xbps only. On Debian use install.sh."; exit 1; }
if ! command -v sudo >/dev/null || ! sudo -v; then
    echo "sudo is not set up. As root run:  visudo  and uncomment  %wheel ALL=(ALL:ALL) ALL"
    echo "(your user must be in the wheel group), then start install-void.sh again."
    exit 1
fi

### Void packages
step "xbps packages"
mapfile -t PKGS < <(pkgs xbps)
sudo xbps-install -Syu xbps
sudo xbps-install -Syu "${PKGS[@]}"

### PipeWire: wireplumber and pipewire-pulse are started by pipewire itself
step "PipeWire"
sudo mkdir -p /etc/pipewire/pipewire.conf.d /etc/alsa/conf.d
for f in /usr/share/examples/wireplumber/10-wireplumber.conf \
         /usr/share/examples/pipewire/20-pipewire-pulse.conf; do
    [ -e "/etc/pipewire/pipewire.conf.d/${f##*/}" ] || sudo ln -s "$f" /etc/pipewire/pipewire.conf.d/
done
for f in /usr/share/alsa/alsa.conf.d/50-pipewire.conf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf; do
    [ -e "$f" ] && [ ! -e "/etc/alsa/conf.d/${f##*/}" ] && sudo ln -s "$f" /etc/alsa/conf.d/ || true
done

### Flatpak: Brave and Telegram (Brave is not in the Void repos)
step "Brave, Telegram"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
for app in com.brave.Browser org.telegram.desktop; do
    flatpak info "$app" >/dev/null 2>&1 \
        || sudo flatpak install -y --noninteractive flathub "$app" \
        || warn "$app install failed"
done

### Wrappers in ~/.local/bin, so the sway config stays the same as on Debian
mkdir -p "$HOME/.local/bin"
if ! command -v brave-browser >/dev/null; then
    printf '#!/bin/sh\nexec flatpak run com.brave.Browser "$@"\n' > "$HOME/.local/bin/brave-browser"
    chmod +x "$HOME/.local/bin/brave-browser"
fi
# Void's VS Code (Code - OSS) is called code-oss; sponux opens files with "code"
if command -v code-oss >/dev/null && ! command -v code >/dev/null; then
    ln -sfn "$(command -v code-oss)" "$HOME/.local/bin/code"
fi

### sponux: pure Python, runs straight from a clone
step "sponux"
SPONUX="$HOME/.local/share/sponux"
if [ -d "$SPONUX/.git" ]; then
    git -C "$SPONUX" pull -q --ff-only || warn "sponux update failed"
else
    git clone -q --depth 1 https://github.com/AutoMaTorn/sponux "$SPONUX" || warn "sponux clone failed"
fi
[ -x "$SPONUX/bin/sponux" ] && ln -sfn "$SPONUX/bin/sponux" "$HOME/.local/bin/sponux"

### BlexMono Nerd Font = IBM Plex Mono with Nerd glyphs
if ! fc-list : family | grep 'BlexMono Nerd Font' >/dev/null; then
    step "BlexMono Nerd Font"
    FONTDIR="$HOME/.local/share/fonts/BlexMonoNerdFont"
    mkdir -p "$FONTDIR"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IBMPlexMono.tar.xz \
        | tar -xJ -C "$FONTDIR" && fc-cache -f "$FONTDIR" \
        || warn "Nerd Font install failed"
fi

# Everything the sway config launches must exist
export PATH="$HOME/.local/bin:$PATH"
missing=()
for c in sway waybar fuzzel swaync kanshi swayidle swaylock grim slurp wl-copy \
         brightnessctl playerctl pactl kitty thunar brave-browser bluetui \
         sponux nmtui gsettings zsh fastfetch nvim pipewire; do
    command -v "$c" >/dev/null || missing+=("$c")
done
[ -x /usr/libexec/polkit-gnome-authentication-agent-1 ] || missing+=("polkit-gnome")
[ ${#missing[@]} -eq 0 ] || warn "missing: ${missing[*]}"

### Configs
step "config symlinks"
for d in sway waybar fuzzel swaync kanshi kitty fastfetch sponux nvim wallpapers; do
    link "$DIR/.config/$d" "$HOME/.config/$d"
done
for v in 3.0 4.0; do
    link "$DIR/.config/gtk-$v/settings.ini" "$HOME/.config/gtk-$v/settings.ini"
done
link "$DIR/.config/xdg-desktop-portal/sway-portals.conf" \
     "$HOME/.config/xdg-desktop-portal/sway-portals.conf"

link "$DIR/zsh/.zshrc" "$HOME/.zshrc"

### zsh: Oh My Zsh + autosuggestions, default shell
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

### System: groups, runit services, login
step "system"
for g in video audio input network bluetooth; do
    getent group "$g" >/dev/null && sudo usermod -aG "$g" "$USER"
done

# NetworkManager replaces the installer's dhcpcd / wpa_supplicant services
sv_disable dhcpcd
sv_disable wpa_supplicant
for s in dbus elogind NetworkManager bluetoothd; do sv_enable "$s"; done

# Session entry for greetd/tuigreet (or any display manager)
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/swayfx.desktop >/dev/null <<EOF
[Desktop Entry]
Name=SwayFX
Comment=Sway with rounded corners and effects
Exec=$DIR/bin/sway-session
Type=Application
DesktopNames=sway
EOF

# greetd + tuigreet as the login screen on tty7 (tty1-6 keep their getty)
sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 7

[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions --power-shutdown 'loginctl poweroff' --power-reboot 'loginctl reboot'"
user = "_greeter"
EOF
sv_enable greetd

step "done"
echo "Reboot, pick SwayFX on the login screen."
if grep -qs 'sway' "$HOME/.bash_profile" "$HOME/.zprofile" 2>/dev/null; then
    warn "~/.bash_profile or ~/.zprofile still starts sway on tty1. Remove that line: greetd starts it now."
fi
if lspci 2>/dev/null | grep -qi 'vga.*nvidia' && [ ! -d /sys/module/nvidia ]; then
    warn "NVIDIA GPU without the nvidia driver loaded. See README (Void + NVIDIA)."
fi

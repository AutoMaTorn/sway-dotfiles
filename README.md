# sway-dotfiles

Sway (Wayland) session: sway, waybar, fuzzel, swaync, kanshi, portal config,
plus kitty, nvim, zsh, fastfetch, sponux and the wallpaper.

    ./install.sh

Needs: sway waybar fuzzel swaync kanshi swayidle swaylock grim slurp xdg-desktop-portal-wlr.

## SwayFX (rounded corners)

Window corners need SwayFX 0.5.1 + scenefx 0.3 (match Debian 13's wlroots 0.18),
built from source into `~/.local`. Start the session with `bin/sway-session`.
For a login-manager entry, create `/usr/share/wayland-sessions/swayfx.desktop`
with `Exec=/home/<user>/sway-dotfiles/bin/sway-session`.

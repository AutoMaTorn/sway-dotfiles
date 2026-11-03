# sway-dotfiles

Sway (Wayland) session: SwayFX, waybar, fuzzel, swaync, kanshi, portal config,
plus kitty, zsh (Oh My Zsh, agnoster), fastfetch, sponux, the wallpaper and neovim.

## Install on a clean Debian 13

Minimal netinst is enough (no desktop needed). Your user must have sudo:

    su -c "apt install sudo git && usermod -aG sudo $USER"   # once, then re-login
    git clone https://github.com/AutoMaTorn/sway-dotfiles ~/sway-dotfiles
    ~/sway-dotfiles/install.sh
    sudo reboot

`install.sh` is safe to re-run. It:

- installs the packages from `packages.txt` (`[apt]` and the `[build]` deps);
- adds Brave, sponux and bluetui (.deb from GitHub releases) and Telegram (flatpak);
- installs BlexMono Nerd Font into `~/.local/share/fonts`;
- builds SwayFX 0.5.1 + scenefx 0.3 into `~/.local` (rounded corners);
- symlinks the configs into `~/.config` and `~/.zshrc` (old files are kept as `*.bak.<time>`);
- installs Oh My Zsh + zsh-autosuggestions and makes zsh your login shell;
- adds the `SwayFX` session to `/usr/share/wayland-sessions` and, if there is no
  display manager, sets up greetd + tuigreet as the login screen.

Then pick **SwayFX** on the login screen. If Wi-Fi was configured by the Debian
installer, remove its `wl*` lines from `/etc/network/interfaces` so NetworkManager
(`nmtui`, waybar) can manage it.

## Install on Void Linux (glibc)

A base install is enough. Your user must be in `wheel` with sudo enabled
(`visudo`, uncomment `%wheel ALL=(ALL:ALL) ALL`):

    sudo xbps-install -Su xbps git
    git clone https://github.com/AutoMaTorn/sway-dotfiles ~/sway-dotfiles
    ~/sway-dotfiles/install-void.sh
    sudo reboot

`install-void.sh` does the same as `install.sh`, the Void way:

- packages from `packages-void.txt`; SwayFX comes from the Void repo, nothing is built;
- Brave and Telegram from flatpak (a `~/.local/bin/brave-browser` wrapper keeps `$super+w`);
- sponux cloned to `~/.local/share/sponux` and linked into `~/.local/bin`;
- PipeWire wired to wireplumber + pipewire-pulse; sway starts it (no systemd user units);
- runit services: dbus, elogind, NetworkManager, bluetoothd, greetd (tuigreet on tty7);
  dhcpcd and wpa_supplicant from the installer are disabled so NetworkManager owns the network.

The configs are shared with Debian: the power menu uses `loginctl`, and
`bin/sway-session` starts a dbus session when there is none.

### NVIDIA

Install the driver before the first login (needs `void-repo-nonfree`):

    sudo xbps-install -S void-repo-nonfree && sudo xbps-install -S nvidia linux-headers

Add `nvidia-drm.modeset=1 nvidia-drm.fbdev=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in
`/etc/default/grub`, then `sudo update-grub && sudo xbps-reconfigure -fa` and reboot.
`bin/sway-session` sees the loaded `nvidia` module and adds `--unsupported-gpu` and the
needed variables itself. Don't set `WLR_RENDERER=vulkan`: SwayFX has only the GLES renderer.

## Other terminals

The agnoster prompt needs a Nerd Font. kitty is already set up; in VS Code add
`"terminal.integrated.fontFamily": "'BlexMono Nerd Font Mono', monospace"`.

## Neovim

`.config/nvim` is linked to `~/.config/nvim`: no plugins, just line numbers, indent,
the `mono` theme and `Ctrl-h/j/k/l` to move between windows.

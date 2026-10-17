# sway-dotfiles

Sway (Wayland) session: SwayFX, waybar, fuzzel, swaync, kanshi, portal config,
plus kitty, zsh (Oh My Zsh, agnoster), fastfetch, sponux and the wallpaper.

## Install on a clean Debian 13

Minimal netinst is enough (no desktop needed). Your user must have sudo:

    su -c "apt install sudo git && usermod -aG sudo $USER"   # once, then re-login
    git clone https://github.com/AutoMaTorn/sway-dotfiles ~/sway-dotfiles
    ~/sway-dotfiles/install.sh
    sudo reboot

`install.sh` is safe to re-run. It:

- installs the packages from `packages.txt` (`[apt]` and the `[build]` deps);
- adds Brave, sponux and bluetui (.deb from GitHub releases) and Telegram (flatpak);
- installs JetBrainsMono Nerd Font into `~/.local/share/fonts`;
- builds SwayFX 0.5.1 + scenefx 0.3 into `~/.local` (rounded corners);
- symlinks the configs into `~/.config` and `~/.zshrc` (old files are kept as `*.bak.<time>`);
- installs Oh My Zsh + zsh-autosuggestions and makes zsh your login shell;
- adds the `SwayFX` session to `/usr/share/wayland-sessions` and, if there is no
  display manager, sets up greetd + tuigreet as the login screen.

Then pick **SwayFX** on the login screen. If Wi-Fi was configured by the Debian
installer, remove its `wl*` lines from `/etc/network/interfaces` so NetworkManager
(`nmtui`, waybar) can manage it.

## Other terminals

The agnoster prompt needs a Nerd Font. kitty is already set up; in VS Code add
`"terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font Mono', monospace"`.

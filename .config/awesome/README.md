# AwesomeWM Configuration

My configuration for AwesomeWM.

![demo](./.docs/demo.png)

## Prerequisites

This configuration is designed only to work on Arch Linux. It may work on others, but there's no guarantee.

As of the time writing this, you need to use the `awesome-git` package, *not* the regular `awesome` package. It contains newer features that this configuration relies on.

### Quick Install

```bash
sudo pacman -S picom feh xorg-xinput brightnessctl pamixer ffmpeg wezterm firefox nemo discord neovim
git clone https://github.com/vi013t/dotfiles.git
cp -r ./dotfiles/.config/awesome ~/.config/awesome
```

### Manual Install

This configuration requires the following programs to be installed:

- [picom](https://github.com/yshui/picom) - For compositing
- [feh](https://feh.finalrewind.org/) - For applying wallpapers
- [xinput](https://wiki.archlinux.org/title/Xinput) - For enabling touchpad support
- [brightnessctl](https://github.com/Hummer12007/brightnessctl) - For changing brightness
- [pamixer](https://github.com/cdemoulins/pamixer) - For changing volume
- [ffmpeg](https://www.ffmpeg.org/) - For playing sounds (such as when adjusting volume)

On Arch, you can install them like so:

```bash
sudo pacman -S picom feh xorg-xinput brightnessctl pamixer ffmpeg
```

The default programs that the configuration will try to use are as follows, which are also required unless you plan to change them:

- [wezterm](https://wezfurlong.org/wezterm/index.html) - Terminal
- [firefox](https://www.mozilla.org/en-US/firefox/) - Browser
- [nemo](https://github.com/linuxmint/nemo) - File Explorer
- [discord](https://discord.com/) - Chat
- [neovim](https://neovim.io/) - Editor

On Arch, you can install them as well:

```bash
sudo pacman -S wezterm firefox nemo discord neovim
```

## Usage

Pressing `windows` will open the start menu. Pressing `windows` again will close it. Typing while in the start menu will search for an app to launch.

Pressing `windows + [1 - 5]` will switch to that tag, between 1 and 5.

Pressing ``windows + ` `` will open the sidebar.

## Customization

All assets used by this configuration are stored in `/assets`. Replace the ones of your choosing to customize.

Also see `preferences.lua`.

# AwesomeWM Configuration

My configuration for AwesomeWM.

![demo](./.docs/demo.png)

## Prerequisites

This configuration is designed only to work on Arch Linux. It may work on others, but there's no guarantee.

As of the time writing this, you need to use the `awesome-git` package, *not* the regular `awesome` package. It contains newer features that this configuration relies on.

### Quick Install

```
git clone https://github.com/vi013t/dotfiles.git
cp -r ./dotfiles/.config/awesome ~/.config/awesome
sudo pacman -S picom feh xorg-xinput brightnessctl pamixer wezterm firefox nemo discord neovim
```

### Manual Install

This configuration requires the following programs to be installed:

- picom
- feh
- xinput
- brightnessctl
- pamixer

On Arch, you can install them like so:

```bash
sudo pacman -S picom feh xorg-xinput brightnessctl pamixer
```

The default programs that the configuration will try to use are as follows, which are also required unless you plan to change them:

- wezterm
- firefox
- nemo
- discord
- honey
- neovim

On Arch, you can install them as well:

```bash
sudo pacman -S wezterm firefox nemo discord neovim
cargo install honey-calculator
```

## Usage

Pressing `windows` will open the start menu. Pressing `windows` again will close it. Typing while in the start menu will search for an app to launch.

Pressing `windows + [1 - 5]` will switch to that tag, between 1 and 5.

Pressing ``windows + ` `` will open the sidebar.

## Customization

All assets used by this configuration are stored in `/assets`. Replace the ones of your choosing to customize.

Also see `preferences.lua`.

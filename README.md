![demo](./.docs/demo.png)

My dotfiles, including configuration for:

- [AwesomeWM](https://awesomewm.org/)
- [Cfg](https://github.com/vi013t/cfg)
- [Darling](https://github.com/darling-package-manager/darling)
- [Joshuto](https://github.com/kamiyaa/joshuto)
- [Neovim](https://neovim.io/)
- [OneDrive](https://abraunegg.github.io/)
- [Picom](https://github.com/yshui/picom)
- [VSCodium](https://vscodium.com/)
- [Wezterm](https://wezfurlong.org/wezterm/index.html)

## Installation

To use ALL of these dotfiles (which I only recommend if you're future me on a new machine), clone it and move its contents into `~`:

```bash
git clone https://github.com/vi013t/dotfiles.git
cd dotfiles
mv * ~/
if command -v darling ; then darling all load-installed ; fi 
```
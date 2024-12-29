# Font Assets

This folder contains fonts used by this config. The fonts are automatically installed upon installation of this config if the install script is used. The files in this folder can be deleted after installation.

Note that fonts are pulled from *your system*, *not* this folder. Placing fonts in here is not enough to reference them. To install a font on your system, download the font files (usually `.ttf` or `.otf` files) and place them in `~/.local/share/fonts`. Then, assuming you have `fontconfig` (installed by default with this configuration if you used the install script), run:

```bash
fc-cache -v
```

To see all fonts on your system assuming you have `ripgrep`, `coreutils`, and `fontconfig` (all installed by default with this configuration if you used the install script), run:

```bash
fc-list | rg ":([^,]*):style" -or '$1' --color=never | sort | uniq
```

# Install packages
echo "Installing required packages..."
sudo pacman -S coreutils fontconfig wireless_tools picom flameshot feh xorg-xinput brightnessctl pamixer ffmpeg ripgrep wezterm firefox nemo discord neovim spotify-launcher

# Install Rust if it isn't already
if !command -v cargo 2>&1 >/dev/null ; then
	echo "Installing Rust..."
	sudo pacman -S rustup
	. "$HOME/.cargo/env"
	rustup default stable
fi

# Install required Rust crates
echo "Installing Rust crates..."
cargo install silico-calculator

# Download the config
echo "Downloading AwesomeWM configuration..."
git clone https://github.com/vi013t/dotfiles.git

# Check for existing configuration
if [ -d ~/.config/awesome ] ; then
	echo "Backing up current configuration to ~/.config/awesome_old..."
	mv ~/.config/awesome ~/.config/awesome_old
fi

# Copy the config over
echo "Copying downloaded config into ~/.config/awesome..."
mkdir -p ~/.config
cp -r ./dotfiles/.config/awesome ~/.config/awesome

# Remove the downloaded dotfiles
echo "Removing original downloaded config..."
rm ./dotfiles -rf

# Install fonts
echo "Installing fonts..."
mkdir -p ~/.local/share/fonts
cp ~/.config/awesome/assets/fonts/* ~/.local/share/fonts
fc-cache -v

# Finish
echo "Installation complete! Reload AwesomeWM for changes to take effect."

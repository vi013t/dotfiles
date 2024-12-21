# Install packages
echo "Installing required packages..."
sudo pacman -S picom flameshot feh xorg-xinput brightnessctl pamixer ffmpeg wezterm firefox nemo discord neovim spotify-launcher ripgrep

# Install Rust if it isn't already
if !command -v cargo 2>&1 >/dev/null ; then
	sudo pacman -S rustup
	. "$HOME/.cargo/env"
	rustup default stable
fi

# Install required Rust crates
cargo install silico-calculator

# Download the config
echo "Downloading AwesomeWM configuration..."
git clone https://github.com/vi013t/dotfiles.git

# Check for existnig configuration
if [ -d ~/.config/awesome ] ; then
	echo "Backing up current configuration to ~/.config/awesome_old..."
	mv ~/.config/awesome ~/.config/awesome_old
fi

# Copy the config over
echo "Copying downloaded config into ~/.config/awesome..."
cp -r ./dotfiles/.config/awesome ~/.config/awesome

# Remove the downloaded dotfiles
echo "Removing original downloaded config..."
rm ./dotfiles -rf

# Finish
echo "Installation complete! Reload AwesomeWM for changes to take effect."

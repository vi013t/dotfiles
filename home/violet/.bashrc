# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Private variables such as API keys
if [ -f ~/.bash_private ]; then 
	. ~/.bash_private
fi

# Set Wezterm info
if [ ! -f /usr/share/terminfo/w/wezterm ] ; then
	curl https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo | tic -x -
fi

# Environment variables
export PS1="├─ " # Set Bash prompt
export BUN_INSTALL="$HOME/.bun" # Set Bun install location
export MANPAGER='nvim +Man!' # Set Neovim as the editor for man pages
export MANWIDTH=999 # Set the max width for manpages
export TERM="wezterm" # Set the terminal type
export EDITOR="nvim" # Editor for things like cfg

# PATH variables
export PATH="$BUN_INSTALL/bin:$PATH"

# Aliases
alias i="sudo pacman -S" # Install a package
alias img="wezterm imgcat" # View images with Wezterm
alias ls='ls -A1 --color=auto' # Add colors to ls
alias grep='grep --color=auto' # Add colors to grep
alias neofetch="neofetch --iterm2 ~/Pictures/arch.png --size 400" # Neofetch with image
alias code="codium . -r" # Open in VSCode
alias weather="curl wttr.in" # Show weather
alias open="xdg-open" # Open file
alias battery="echo $(cat /sys/class/power_supply/BAT0/capacity)%" # Show battery
alias fonts="fc-list | rg ':([^,]*):style' -or '\$1' --color=never | sort | uniq" # List fonts

# Session Information
alias x11?="loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}' | cut -d'=' -f2"
alias wayland?="loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}' | cut -d'=' -f2"
alias de?="echo $DESKTOP_SESSION"

# Wrapper around joshuto for preivews and exiting into cwd with q
function files() {
	ID="$$"
	mkdir -p /tmp/$USER
	OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
	env joshuto --output-file "$OUTPUT_FILE" $@
	exit_code=$?

	case "$exit_code" in
		0)
			;;
		101)
			JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
			cd "$JOSHUTO_CWD"
			;;
		102)
			;;
		*)
			echo "Exit code: $exit_code"
			;;
	esac
}

# Update arch stuff
function update() {
	sudo pacman -Syu --noconfirm # Update official packages
	yes | yay -Syu # Update AUR packages 
	clean # Clean up
	[ -d ~/go ] && rm ~/go -rf # Remove go folder
}

# Clean old packages
function clean() {
	sudo pacman -Scc --noconfirm # Fully clear package cache
	sudo paccache -ruk0 # Remove old package versions
	sudo pacman -Qdtq | ifne sudo pacman -Rns - # Remove orphans
}

# Compile .ll (LLVM) files to native executable
function llvmc() {
	fname="${1%.*}"
	llc -filetype=obj $1 -o "$fname.o"
	clang "$fname.o" -o "$fname"
	rm "$fname.o"
}

# Run C files
function c() {
	set -e
	fname="${1%.*}"
	gcc -o "$fname" "$fname.c"
	./"$fname"
	rm "$fname"
}

# Convert markdown to PDF
function md() {
	fname="${1%.*}"
	pandoc "$1" -o "$fname.pdf" -V geometry:margin=1in -f markdown-implicit_figures -V colorlinks=true -V linkcolor=blue -V urlcolor=blue -V tocolor=blue
}

# List largest packages
function storage() {
	pacman -Qei | grep -E '^(Name|Installed)' | cut -f2 -d':' | paste - - | column -t | sort -nrk 2 | grep MiB --color=none
}

# Set tab size
tabs -4

# Source Cargo
. "$HOME/.cargo/env"

# Luaver
[ -s ~/.luaver/luaver ] && . ~/.luaver/luaver
[ -s ~/.luaver/completions/luaver.bash ] && . ~/.luaver/completions/luaver.bash

# Pls
eval "$(pls --init)"
cd .

# Touchpad
xinput set-prop "VEN_04F3:00 04F3:320F Touchpad" "libinput Tapping Enabled" 1

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Private variables such as API keys
# . ~/.bash_private

# Environment variables
export PS1="┣━ " # Set Bash prompt
export BUN_INSTALL="$HOME/.bun" # Set Bun install location
export MANPAGER='nvim +Man!' # Set Neovim as the editor for man pages
export MANWIDTH=999 # Set the max width for manpages
export TERM="wezterm" # Set the terminal type: $ curl https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo | tic -x -

# PATH variables
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:/home/violet/.local/share/darling/source/target/release"
export PATH="/home/violet/.scripts/lazy:$PATH"

# Sourced Scripts
sourced_scripts=($(ls /home/violet/.scripts/sourced))
for script in "${sourced_scripts[@]}" ; do
	. "/home/violet/.scripts/sourced/$script"
done

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
			# z "$JOSHUTO_CWD"
			cd "$JOSHUTO_CWD"
			;;
		102)
			;;
		*)
			echo "Exit code: $exit_code"
			;;
	esac
}

# Quickly configure dotfiles
function cfg() {
	if [[ $# < 1 ]] ; then
		echo "Error: Please provide one argument; For examle, cfg nvim"
		return 1
	fi

	case "$1" in
		"darling")
			nvim ~/.config/darling/darling.toml
			;;
		"joshuto")
			nvim ~/.config/joshuto/joshuto.toml
			;;
		"lotus")
			nvim ~/.config/lotus/rc.lotus
			;;
		"nvim")
			nvim ~/.config/nvim/init.lua
			;;
		"bash")
			nvim ~/.bashrc
			;;
		"stylua")
			nvim ~/.config/stylua/stylua.toml
			;;
		"wezterm")
			nvim ~/.config/wezterm/wezterm.lua
			;;
		*)
			echo "Unknown configuration: $1"
			;;
	esac
}

_cfg() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "bash lotus nvim bash stylua wezterm" -- $cur) )
}
complete -F _cfg cfg

# Print the here directory
cd .

# Aliases
alias i="sudo pacman -S" # Install a package
alias img="wezterm imgcat" # View images with Wezterm
alias ls='ls --color=auto' # Add colors to ls
alias grep='grep --color=auto' # Add colors to grep
alias neofetch="neofetch --iterm2 ~/Pictures/catgirl.png --size 800"
alias rs=". ~/.bashrc"
alias code="codium . -r"

function update() {
	sudo pacman -Syu --noconfirm # Update official packages
	yes | yay -Syu # Update AUR packages 
	paccache -rk1 # Remove older package versions
	sudo paccache -ruk0 # Remove uninstalled packages
	sudo pacman -Qdtq | sudo pacman -Rns - # Remove orphans
	rm ~/go -rf # Remove go folder
}

# Session Information
alias x11?="loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}' | cut -d'=' -f2"
alias wayland?="loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}' | cut -d'=' -f2"
alias de?="echo $DESKTOP_SESSION"

# Compile .ll (LLVM) files to native executable
function llvmc() {
	fname="${1%.*}"
	llc -filetype=obj $1 -o "$fname.o"
	clang "$fname.o" -o "$fname"
	rm "$fname.o"
}

# Run C files
function c() {(
	set -e
	fname="${1%.*}"
	gcc -o "$fname" "$fname.c"
	./"$fname"
	rm "$fname"
)}

# Convert markdown to PDF
function md() {
	fname="${1%.*}"
	pandoc "$1" -o "$fname.pdf" -V geometry:margin=1in -f markdown-implicit_figures -V colorlinks=true -V linkcolor=blue -V urlcolor=blue -V tocolor=blue
}

# Clean old packages
function clean() {
	paccache -rk1
	sudo paccache -ruk0
	sudo pacman -Qdtq | sudo pacman -Rns - # Remove orphans
}

# Set tab size
tabs -4

. "$HOME/.cargo/env"

# Luaver
[ -s ~/.luaver/luaver ] && . ~/.luaver/luaver
[ -s ~/.luaver/completions/luaver.bash ] && . ~/.luaver/completions/luaver.bash

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

function color() {
	echo "\033[38;2;$1;$2;${3}m"
}

NO_COLOR='\033[0m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'

# Print the file icon of a given filename
function file_to_icon() {
	case $1 in
		*.bash)
			echo ""
			;;
		bun.lockb)
			echo "🥟"
			;;
		*.c)
			echo "$(color 100 100 255)"
			;;
		*.conf)
			echo "$(color 150 150 150)"
			;;
		*.cpp)
			echo ""
			;;
		*.cs)
			echo ""
			;;
		*.d)
			echo ""
			;;
		*.dark)
			echo ""
			;;
		*.ex)
			echo ""
			;;
		*.gyp)
			echo ""
			;;
		*.h)
			echo "$(color 200 100 255)ﴧ"
			;;
		*.html)
			echo -e "$(color 227 76 38)"
			;;
		*.java)
			echo ""
			;;
		*.jpg)
			echo ""
			;;
		*.js)
			echo "$(color 241 224 90)"
			;;
		*.json)
			echo "$(color 255 255 0)"
			;;
		LICENSE)
			echo "$(color 255 255 150)"
			;;
		*.lock)
			echo "$(color 255 255 150)"
			;;
		*.lua)
			echo "$(color 100 125 255)"
			;;
		*.md)
			echo "$(color 255 255 255)"
			;;
		*.png)
			echo ""
			;;
		*.py)
			echo "$(color 225 225 50)"
			;;
		*.rb)
			echo "$(color 255 50 50)"
			;;
		*.rkt)
			echo "λ"
			;;
		*.rs)
			echo "$(color 222 165 132)"
			;;
		*.svg)
			echo "$(color 255 255 100)󰜡"
			;;
		*.toml)
			echo "$(color 150 150 150)"
			;;
		*.ts)
			echo "$(color 49 120 198)"
			;;
		*.vsix)
			echo "$(color 100 100 255)󰨞"
			;;	
		*.zig)
			echo "$(color 236 145 92)"
			;;
		*.zip)
			echo "$(color 255 50 50)"
			;;
		plasma*)
			echo "$(color 255 255 255)"
			;;
		kde*)
			echo "$(color 255 255 255)"
			;;
		*rc)
			echo "$(color 150 150 150)"
			;;
		LICENSE*)
			echo "$(color 255 150 150)󰿃"
			;;
		*)
			echo ""
			;;
	esac
}

function directory_to_icon() {
	case $1 in
		*) 	
			echo "${BLUE}"
			;;
	esac
}

# Overload the cd function to list non-hidden files and folders in the
# cd'd directory. Before this I was in a never ending loop of cd ls cd ls cd ls
function cd() {
    NOCOLOR='\033[0m'

	# __zoxide_z "$1"
	builtin cd "$1"
	clear
	echo "┏━ $PWD:"
	echo "┃"
	FILES=$(ls -pv | grep -v /)
	DIRECTORIES=$(ls -pv | grep /)
	readarray -t FILELIST <<<"$FILES"
	readarray -t DIRLIST <<<"$DIRECTORIES"

	for DIRECTORY in "${DIRLIST[@]}"; do
        DIRECTORY=${DIRECTORY%/*}
		dir_icon=$(directory_to_icon $DIRECTORY)
		(echo "$DIRECTORY" | grep -Eq \\S ) && echo -e "┃ $dir_icon  $DIRECTORY${NOCOLOR}"
	done
	for FILE in "${FILELIST[@]}"; do
		file_icon=$(file_to_icon $FILE)	
		(echo "$FILE" | grep -Eq \\S ) && echo -e "┃ $file_icon  ${WHITE}$FILE${NOCOLOR}"
	done

    echo "┃"
}

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
		"awesome")
			nvim ~/.config/awesome/rc.lua
			;;
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
		"picom")
			nvim ~/.config/picom/picom.conf
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
	COMPREPLY=( $(compgen -W "awesome bash lotus nvim bash picom stylua wezterm" -- $cur) )
}
complete -F _cfg cfg

# Print the here directory
# z .
cd .

# Source cargo
. "$HOME/.cargo/env"

# Aliases
alias i="sudo pacman -S" # Install a package
alias img="wezterm imgcat" # View images with Kitty
alias ls='ls --color=auto' # Add colors to ls
alias grep='grep --color=auto' # Add colors to grep
alias neofetch="neofetch --iterm2 ~/Pictures/catgirl.png --size 800"
alias update="sudo pacman -Syu && yay -Syu"
alias rs=". ~/.bashrc"
alias code="codium . -r"

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
	paccache -ruk0
	pacman -Qdtq | pacman -Rns - # Remove orphans
}

# Set tab size
tabs -4

export PATH="$PATH:/home/violet/.local/share/darling/source/target/release"

# eval "$(zoxide init bash --no-cmd)"

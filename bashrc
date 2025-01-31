# shellcheck shell=bash disable=SC1090,SC1091,SC2039
# vim: set filetype=sh:
#
# ~/.bashrc
#
# Upstream/source: https://github.com/iddinev/bashrc
#
# Uppercase variables are defined throughout the sections
# and are ment to be exported. Lowercase variables
# are defined in the 'Main' section and are internal,
# they are unset at the end of the file.



## Login

[[ $- != *i* ]] && return


## Main

user_home="$HOME"
own_path=$(readlink -f "${BASH_SOURCE[0]}")
own_name=$(basename "${BASH_SOURCE[0]}")
own_dir=$(dirname "${BASH_SOURCE[0]}")
backup_suffix='BACKUP'
bashrc_name=".bashrc"
bashrc_path="$user_home/$bashrc_name"
use_color=false
local_rc_repo="$user_home/.home_configs.git"
local_bashrc_repo="$user_home/.bashrc.git"

# Upstream/Sources

# Upstream/source for this bashrc.
source_name='bashrc'
# shellcheck disable=SC2034
source_repo="https://github.com/iddinev/bashrc"
source_url="https://raw.githubusercontent.com/iddinev/bashrc/master/bashrc"

# Powerline
# Colors are picked from my custom material theme:
# https://gist.github.com/iddinev/8998241c16642f7502d1e1dc511e7c68
powerline_name=".bash-powerline"
# shellcheck disable=SC2034
powerline_repo="https://github.com/iddinev/bash-powerline"
powerline_url="https://raw.githubusercontent.com/iddinev/bash-powerline/master/.bash-powerline"
powerline_path="$user_home/$powerline_name"

# Fuzzy Finder
# Install info, if fzf is not installed through the system's package manager already.
fuzzyfinder_name=".bash-fuzzyfinder"
fuzzyfinder_repo="https://github.com/junegunn/fzf"
# shellcheck disable=SC2034
fuzzyfinder_url="$fuzzyfinder_repo"
fuzzyfinder_path="$user_home/$fuzzyfinder_name"

# Functions for the main (deploy/install etc) part.

# This whole 'eval' part is needed in order not to keep any variable definitions in the env.
eval "function bashrc_update()
{
	l_relogin='no'
	if [[ \$1 == --create-local-git ]] || [[ \$1 == -c ]]; then
		[[ -d \"$local_rc_repo\" ]] || git init --bare \"$local_rc_repo\"
		[[ -d \"$local_bashrc_repo\" ]] || git init --bare \"$local_bashrc_repo\"
		l_relogin='yes'
	else
		if command -v wget 1>/dev/null; then
			wget \"$source_url\" -O \"$bashrc_path\"
			l_relogin='yes'
		else
			echo \"wget (used to download stuff from github) not found!\"
		fi
	fi
	if [[ \"\$l_relogin\" == \"yes\" ]]; then
		echo -e '\\nRelogin to the shell to start in a clean environment.\\n'
	fi

}"

# shellcheck disable=SC1078,SC1079,SC2027,SC2086
eval "function bashrc_update_plugins()
{
	if command -v wget 1>/dev/null; then
		# Powerline
		wget \"$powerline_url\" -O \"$user_home/$powerline_name\"
		# Fuzzy Finder
		# We handle the appropriate sourcing ourselves.
		if ! command -v fzf 1>/dev/null; then
			if [ -d \"$fuzzyfinder_path\" ]; then
				l_pwd=\$(pwd)
				cd \"$fuzzyfinder_path\" && git pull && \
					./install --64 --bin
				cd \"\$l_pwd\"
			else
				git clone --depth 1 "$fuzzyfinder_repo" "$fuzzyfinder_path" && \
					"$fuzzyfinder_path/install" --64 --bin
			fi
		else
			echo 'fzf already available on the system.'
		fi
		echo -e '\\nRelogin to the shell to start in a clean environment.\\n'
	else
		echo \"wget (used to download stuff from github) not found!\"
	fi
}"

eval "function bashrc_uninstall()
{
	[ -f \"$bashrc_path.$backup_suffix\" ] && mv -v \
		\"$bashrc_path.$backup_suffix\" \"$bashrc_path\"
	[ -f \"$powerline_path\" ] && rm -v \"$powerline_path\"
	[ -d \"$fuzzyfinder_path\" ] && rm -rf \"$fuzzyfinder_path\" && \
		echo \"removed '$fuzzyfinder_path'\"
	echo 'Delete the git repos manually - first check if you need to save something from them.'
	echo \"Git repos: $local_rc_repo $local_bashrc_repo\"
	echo -e '\\nRelogin to the shell to start in a clean environment.\\n'
}"

bashrc_help()
{
    cat <<_EOF_

    Check the README at
    https://github.com/iddinev/bashrc

    Usage:
    1)
      $ source bashrc:

         Sources the configs and makes the functions from 2) available.
         Backups the preexisting '.bashrc', moves itself to its place.
         Implies 'bashrc_update -c'.

    2)
      $ bashrc_update [ -c ]

         -c, --create-local-git
             Create local git repos to manage local \$HOME & .bashrc modifications.

     $ bashrc_update_plugins

         Update to the latest plugins from github.

     $ bashrc_uninstall

         Reverts to the old bashrc & removes plugins.
         Intentionally does not remove the local git repos.
         If used, check if you need to save something from them and
         remove them manually.

     $ bashrc_help

         Show this help message.

_EOF_
}

if [[ $own_name == "$source_name" ]]; then
	# Backup the original bashrc.
	[ -f "$bashrc_path"."$backup_suffix" ] || cp -pv "$bashrc_path" "$bashrc_path"."$backup_suffix"
	mv -v "$own_path" "$bashrc_path"
	bashrc_update --create-local-git
	if [ 0 -eq "$(find "$own_dir"\
	-mindepth 1 -maxdepth 1 \! -name '.git' -a \! -name\
	"$own_name" -a \! -name README.md | wc -l)" ] &&\
	[ "$(readlink -f "$PWD")" != "$own_dir" ]; then
		echo "Removing the (uneeded) git repo '$own_dir'."
		rm -rf "$own_dir/.git"
		rm "$own_dir/README.md"
		rmdir -v "$own_dir"
	fi
fi


## Bash options

# Disable flow control (CTRL-S freezing io).
stty -ixon

# Append to the history file, don't overwrite it.
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Do not try to <TAB> expand if nothing is typed.
shopt -s no_empty_cmd_completion


## Env variables

export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=1500

# Compromise until a better theme is supplied upstream.
if command -v bat 1>/dev/null; then
	export BAT_THEME='TwoDark'
fi

# Use vim if available.
if command -v vim 1>/dev/null; then
	export VISUAL='vim'
	export EDITOR=$VISUAL
fi


## Prompts/Colors

# Based on Gentoo's default .bashrc .
if type -P dircolors >/dev/null ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	LS_COLORS=
	if [[ -f ~/.dir_colors ]] ; then
		eval "$(dircolors -b ~/.dir_colors)"
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval "$(dircolors -b /etc/DIR_COLORS)"
	else
		eval "$(dircolors -b)"
	fi
	# Note: We always evaluate the LS_COLORS setting even when it's the
	# default.  If it isn't set, then `ls` will only colorize by default
	# based on file attributes and ignore extensions (even the compiled
	# in defaults of dircolors). #583814
	if [[ -n "${LS_COLORS:+set}" ]] ; then
	# Delete it if it's empty as it's useless in that case.
		unset LS_COLORS
	fi
fi

case "${TERM}" in
	[aEkx]term*|rxvt*|gnome*|konsole*|screen|cons25|*color|*interix|xfce*|linux) use_color=true;;
esac

if "${use_color}" ; then
	if [[ -f $powerline_path ]]; then
		source "$powerline_path"
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;34m\] \W]\$\[\033[00m\] '
	fi
else
	# Show root@ when we don't have colors.
	PS1='[\u@\h \W]\$ '
fi


## Aliases

if "${use_color}" ; then
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -AF'
alias l='ls -CF'
alias less='less -R'

if command -v xclip 1>/dev/null; then
	alias pasteclip="xclip -rmlastnl -selection c -o"
	alias copyclip="xclip -rmlastnl -selection c"
fi

# Manage dot files inside $HOME without messing up any other repo(s) inside $HOME.
if [[ -d $local_rc_repo ]]; then
	# shellcheck disable=SC2139
	alias git_rc="/usr/bin/git --git-dir=$local_rc_repo --work-tree=$user_home"
fi

# Store any local overrides and modifications in a local repo.
if [[ -d $local_bashrc_repo ]]; then
	# shellcheck disable=SC2139
	alias git_bash="/usr/bin/git --git-dir=$local_bashrc_repo --work-tree=$user_home"
fi

if command -v vim 1>/dev/null; then
	alias vim='vim -O'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# shellcheck disable=SC1004
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal \
|| echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# '|| true' is needed otherwise the overall exit code of the sourcing is 1
# if the file is not presetn.
# shellcheck disable=SC2015
[ -f ~/.bash_aliases ] && source ~/.bash_aliases || true


## Functions

# Handy extract.
extract()
{
	if [ -f "$1" ] ; then
		case "$1" in
		*.tar.bz2)     tar xvjf "$1"                ;;
		*.tar.gz)      tar xvzf "$1"                ;;
		*.tar.xz)      tar xvJf "$1"                ;;
		*.tar.zst)     tar -I zstd -xvf "$1"        ;;
		*.bz2)         bunzip2 "$1"                 ;;
		*.rar)         unrar x "$1"                 ;;
		*.gz)          gunzip "$1"                  ;;
		*.tar)         tar xvf "$1"                 ;;
		*.tbz2)        tar xvjf "$1"                ;;
		*.tgz)         tar xvzf "$1"                ;;
		*.zip)         unzip "$1"                   ;;
		*.Z)           uncompress "$1"              ;;
		*.7z)          7z x "$1"                    ;;
		*.rpm)         rpm2cpio "$1" | cpio -idmv   ;;
		*.deb)         ar -xv "$1"                  ;;
		*.xz)          unxz -v "$1"                 ;;
		*)             echo "'$1' cannot be extracted via >${FUNCNAME[0]}<" ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}


## Plugins

# FZF
if command -v fzf 1>/dev/null; then
	# These paths may vary for different OS'es so adjust them as needed.
	# For e.g. on Arch Linux, the fzf package does not populate the
	# /usr/share/bash-completion/completions/ path.
	# Auto-completion
	# ---------------

	[[ $- == *i* ]] && source "/usr/share/fzf/completion.bash" 2>/dev/null
	# Key bindings
	# ------------
	source "/usr/share/fzf/key-bindings.bash" 2>/dev/null
else
	# No need to have this in a separate file as per fzf's install script.
	if [ -d "$fuzzyfinder_path" ]; then
		if [[ ! "$PATH" == *"$fuzzyfinder_path"/bin* ]]; then
			export PATH="${PATH:+${PATH}:}$fuzzyfinder_path/bin"
		fi

		# Auto-completion
		# ---------------
		[[ $- == *i* ]] && source "$fuzzyfinder_path/shell/completion.bash" 2>/dev/null

		# Key bindings
		# ------------
		source "$fuzzyfinder_path/shell/key-bindings.bash" 2>/dev/null
	fi
fi

if command -v fzf 1>/dev/null; then
	# Can't use '``' as of https://github.com/junegunn/fzf/issues/3459
	export FZF_COMPLETION_TRIGGER='~~'
	# Minimalistic look for the fzf menu, colors are based on my material theme(s).
	# Colors are picked to 'work' with both a dark and a light theme.
	export FZF_DEFAULT_OPTS="--reverse --exact --height=20% --no-bold \
		--color='16,gutter:-1,bg+:-1' \
		--color='border:-1,info:-1'"
	# Include hidden files by default, no directories.
	export FZF_DEFAULT_COMMAND="command find -L . -mindepth 1 \
		-name .git -prune -o -type f -print 2>/dev/null | cut -c3-"

	# Slightly better (than the default) ATL_C.
	export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --height=35% --preview  \
		'ls -C --color=always {} | head -30' --preview-window=:wrap"
	export FZF_ALT_C_COMMAND="command find -L ~ -mindepth 1 \\( -fstype 'sysfs' -o \
		-fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' -o \
		-name .git -o -name .hg -o -name .svn \\) -prune \
		-o -type d -print 2> /dev/null"

	export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
	export FZF_CTRL_T_COMMAND="command find -L . -mindepth 1 \
		-name .git -prune -o \\( -type d -o -type f \\) -print 2>/dev/null | cut -c3-"

	export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS"

	# Interactive man (when called whithout args).
	fzf_man()
	{
		# shellcheck disable=SC2021
		if [ "$#" -gt 0 ]; then
			man "$@"
		else
			l_result=$(apropos . | sed 's/^\(.*\)\([0-9][[:alpha:]]*\)/\2\t\1/' | \
			cut -d ' ' -f -2 | tr --delete '[()]' | \
			fzf --height=50% --preview 'man {1} {2}' --preview-window=:wrap)
			if [ -n "$l_result" ]; then
				# shellcheck disable=SC2086
				man $l_result
				# Append selected 'man <result>' to history, instead of just 'man'.
				history -s "man $l_result"
			fi
		fi
	}

	# Slightly better than the upstream supplied one:
	# doesn't include dirs in the output.
	_fzf_compgen_path() {
		command find -L "$1" \
			\( -name .git -o -name .hg -o -name .svn \) -prune -o \
			\( -type f -o -type l \) -print 2> /dev/null | sed 's@^\./@@'
	}

	_fzf_comprun()
	{
		local command=$1
		shift

		case "$command" in
			cd)
				fzf "$@" --height=50% --preview \
				'ls -C --color=always {} | head -30' \
				--preview-window=:wrap
			;;
			export|unset)
				fzf "$@" --preview "eval 'echo \$'{}" \
				--preview-window=:wrap
			;;
			vim)
				if command -v bat 1>/dev/null; then
					fzf "$@" --height=45% \
					--preview "bat -pp --color=always -r :40 {}" \
					--preview-window=:wrap
				else
					fzf "$@" --height=45% \
					--preview "head -40 {}" \
					--preview-window=:wrap
				fi
			;;
			*)
				fzf "$@"
			;;
		esac
	}

	alias man="fzf_man"

	# Easily copy full links from anywhere in the home dir to the clipboard.
	alias freadlink="command find -L ~ -mindepth 1 \
		-name .git -prune -o -name .hg -prune -o -name .svn -prune -o \
		\\( -type d -o -type f -o -type l \\) -print 2> /dev/null | \
		fzf | xargs readlink -f | xclip -rmlastnl -selection c"

fi

# Bitwarden-CLI
if command -v bw 1>/dev/null; then
	password_login()
	{
		command bw login --raw "$BW_EMAIL" > /tmp/BW_SESSION
	}

	password_logout()
	{
		command bw logout
	}

	_password_login_check()
	{
		[ -s /tmp/BW_SESSION ]  || ( echo 'Missing/invalid session file - (re)login needed' && return 1 )
	}

	# Per SC2262.
	password_cli()
	{
		! _password_login_check && return 1
		command bw --pretty --session "$(cat /tmp/BW_SESSION)" "$@"
	}

	if command -v jq 1>/dev/null && command -v xclip 1>/dev/null; then

		export BW_CLIP_CLEAR=30

		_password_clear_clip()
		{

			l_cur="$(cat /tmp/BW_CUR 2>/dev/null)"
			rm /tmp/BW_CUR
			sleep "$BW_CLIP_CLEAR"
			[ "$(xclip -selection clip -out)"  = "$l_cur" ] && xclip -selection clip < /dev/null
		}

		export -f _password_clear_clip

		password_get()
		{
			! _password_login_check && return 1
			# '@json' quotes 'null' values produced by bw passwords with no folders.
			# Beware - xclip might need nohup to survive terminal app exit.
			# Command can be sped up if folderId->name is not used.
			password_cli list items \
				| jq -r --argjson keys "$(password_cli list folders \
				| jq 'map({((.id | @json)): .name}) | add')" \
					-r '.[] | select(.login.username and .login.password)
					| [(.login.password, $keys[(.folderId | @json)]), .name, .login.username]
					| join(" ")' \
				| fzf --with-nth 2.. \
				| cut -d ' ' -f 1 | tee /tmp/BW_CUR | xclip -rmlastnl -selection clip

			pkill --full _password_clear_clip >/dev/null 2>&1
			setsid bash -c "_password_clear_clip" >/dev/null 2>&1
		}
	fi
fi


## Other

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable bash completions.
[ -r /usr/share/bash-completion/bash_completion ] && \
	source /usr/share/bash-completion/bash_completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	source /etc/bash_completion
fi

# System completions based on Arch linux (paths may vary on different OS).
# This is the fastest multi-file source possible (still adds around 30%-40% startup time).
[ -d /usr/share/bash-completion/completions ] && source <(cat /usr/share/bash-completion/completions/*) 2>/dev/null


## Unset

unset user_home
unset own_path
unset own_name
unset backup_suffix
unset bashrc_name
unset bashrc_path
unset use_color
unset local_rc_repo
unset local_bashrc_repo
unset source_name
unset source_url
unset source_repo
unset powerline_name
unset powerline_url
unset powerline_repo
unset powerline_path
unset fuzzyfinder_name
unset fuzzyfinder_url
unset fuzzyfinder_repo
unset fuzzyfinder_path



### OVERIDES

# Store all kinds of useful specific overrides and fixes.
# Use/add/modify per machine whenever needed. Feel
# free to keep local override files in version control
# and/or backups.

# '|| true' is needed otherwise the overall exit code of the sourcing is 1
# if the file is not presetn.
# shellcheck disable=SC2015
[ -f ~/.bashrc_override ] && source ~/.bashrc_override || true



# Some useful overrides that I've picked up so far.

## Env variables

# MANUAL FIX FOR XUBUNTU/old XFCE (<4.11??) and RHEL (v6??).
# For some reason the xfce4-terminal in xubuntu
# cannot properly set the TERM var.
#export TERM=xterm-256color

# Some tools like to drop you to a terminal when encountering a problem.
#export OE_TERMINAL_CUSTOMCMD="gnome-terminal"


## Plugins

# Ubuntu
# FZF
#if command -v fzf 1>/dev/null; then
#    # These paths may vary for different OS'es so adjust them as needed.
#    # For e.g. on Arch Linux, the fzf package does not populate the
#    # /usr/share/bash-completion/completions/ path.
#    # Auto-completion
#    # ---------------
#
#    [[ $- == *i* ]] && source "/usr/share/doc/fzf/examples/completion.bash" 2>/dev/null
#    # Key bindings
#    # ------------
#    source "/usr/share/doc/fzf/examples/key-bindings.bash" 2>/dev/null
#fi


## Other

# Set the proper terminal tab title, even though PROMPT_COMMAND will point to a function.
# This fix is needed for some terminal emulators, that cannot handle the custom PROMPT_COMMAND.
# TERM_TITLE='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
# PROMPT_COMMAND="$PROMPT_COMMAND${PROMPT_COMMAND:+; $TERM_TITLE}"


## Unset

# unset TERM_TITLE
# echo -en "\\e]P0112233"
# echo -en "\\e]P1445566"
# echo -en "\\e]P2778899"
# clear

# vim: set filetype=sh:
#
# ~/.bashrc
#
# Upstream/source: https://github.com/iddinev/bashrc



## Login

[[ "$-" != *i* ]] && return


## Main

user_home="$HOME"
own_path="$(readlink -f $BASH_SOURCE)"
own_name="$(basename $BASH_SOURCE)"
backup_suffix='BACKUP'
bashrc_name=".bashrc"
bashrc_path="$user_home/$bashrc_name"
use_color=false
local_rc_repo="$user_home/.home_configs.git"
local_bashrc_repo="$user_home/.bashrc.git"

# Upstream/Sources

# Upstream/source for this bashrc.
source_name='bashrc'
source_dl="https://raw.githubusercontent.com/iddinev/bashrc/master/bashrc"
source_repo="https://github.com/iddinev/bashrc"

# Powerline
bash_powerline_name=".bash_powerline"
bash_powerline_dl="https://raw.githubusercontent.com/iddinev/bash-powerline/master/.bash-powerline"
bash_powerline_repo="https://github.com/iddinev/bash-powerline"
bash_powerline_path="$user_home/.bash_powerline"

# Functions for the main (deploy/install etc) part.

function _bashrc_deploy()
{
	if _bashrc_check_wget; then
		# Backup the original bashrc (dont backup updates of this one though).
		[ -f "$bashrc_path"."$backup_suffix" ] || cp -p "$bashrc_path" "$bashrc_path"."$backup_suffix"
		wget "$source_dl" -O "$bashrc_path"
		[[ -d "$local_rc_repo" ]] || git init --bare "$local_rc_repo"
	fi
	_bashrc_relogin_msg
}

function _bashrc_deploy_plugins()
{
	if _bashrc_check_wget; then
		wget "$bash_powerline_dl" -O "$user_home/$bash_powerline_name"
	fi
	_bashrc_relogin_msg
}

function _bashrc_install()
{
	[[ -d "$local_bashrc_repo" ]] || git clone --bare "$source_repo" "$local_bashrc_repo"
	[[ -d "$local_rc_repo" ]] || git init --bare "$local_rc_repo"
	_bashrc_deploy
	_bashrc_deploy_plugins
}

function _bashrc_uninstall()
{
	[ -f "$bashrc_path."$backup_suffix"" ] && mv -v "$bashrc_path"."$backup_suffix" "$bashrc_path"
	[ -f "$bash_powerline_path" ] && rm -v "$bash_powerline_path"
	echo 'Delete the git repos manually - first check if you need to save something from them.'
	_bashrc_relogin_msg
}

function _bashrc_relogin_msg()
{
	echo ''
	echo "Relogin to the shell to start in a clean environment."
	echo ''
}

function _bashrc_check_wget()
{
	rc=0
	which wget 2>/dev/null 1>&2 || { echo 'wget not found!'; rc=1; }
	return $rc
}


function _bashrc_help()
{
	cat <<- _EOF_

	Check the README at
	https://github.com/iddinev/bashrc

	Usage:
	$ source bashrc [options]


	Options:
		-d | --deploy    Download & setup the latest bashrc from github. Can be used for upgrading.
		-i | --install   Download & setup the latest bashrc github repo. Implies '-p'.
		-p | --plugins   Download & setup the latest plugins from github. Can be used of upgrading.
		-u | --uninstall Revert previous bashrc and remove plugins. Git repos have to be removed
		                 manually.
		-h | --help      Show this help message, don't download/setup/modify files.

	All the options also source the configs.
	_EOF_
}

case "$1" in
	-d | --deploy)
		_bashrc_deploy
	;;
	-i | --install)
		_bashrc_install
	;;
	-p | --plugins)
		_bashrc_deploy_plugins
	;;
	-u | --uninstall)
		_bashrc_uninstall
	;;
	-h | --help)
		_bashrc_help
	;;
esac


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

export HISTCONTROL=ignoredups:ignorespace

# Use vim if available.
if [ "$(which vim 2>/dev/null)" ]; then
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
	[aEkx]term*|rxvt*|gnome*|konsole*|screen|cons25|*color|*interix|xfce*) use_color=true;;
esac

if "${use_color}" ; then
	if [ -f "$bash_powerline_path" ]; then
		source "$bash_powerline_path"
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;34m\] \W]\$\[\033[00m\] '
	fi
else
	# Show root@ when we don't have colors.
	PS1='[\u@\h \W]\$ '
fi


## Aliases

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

if "${use_color}" ; then
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Fuzzy Finder: https://github.com/junegunn/fzf
# install git clone --depth 1 https://github.com/junegunn/fzf.git ~/.bash-fzf && ./fzf/install  --no-zsh --no-fish --key-bindings --completion --no-update-rc
# if [ -f ~/.fzf.bash ]; then
	# source ~/.fzf.bash
	# export FZF_COMPLETION_TRIGGER='~~'
	# export FZF_DEFAULT_OPTS='--exact --tiebreak=begin --preview "[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -500"'
# fi

# Manage dot files inside $HOME without messing up any other repo(s) inside $HOME.
if [[ -d "$local_rc_repo" ]]; then
	alias git_rc="/usr/bin/git --git-dir=$local_rc_repo --work-tree=$user_home"
fi

if [[ -d "$local_bashrc_repo" ]]; then
	alias git_bash="/usr/bin/git --git-dir=$local_bashrc_repo --work-tree=$user_home"
fi

alias vim='vim -O'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal'\
'|| echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


## Functions

# Handy extract.
function extract()
{
	if [ -f "$1" ] ; then
		case "$1" in
		*.tar.bz2)     tar xvjf $1                ;;
		*.tar.gz)      tar xvzf $1                ;;
		*.tar.xz)      tar xvJf $1                ;;
		*.bz2)         bunzip2 $1                 ;;
		*.rar)         unrar x $1                 ;;
		*.gz)          gunzip $1                  ;;
		*.tar)         tar xvf $1                 ;;
		*.tbz2)        tar xvjf $1                ;;
		*.tgz)         tar xvzf $1                ;;
		*.zip)         unzip $1                   ;;
		*.Z)           uncompress $1              ;;
		*.7z)          7z x $1                    ;;
		*.rpm)         rpm2cpio "$1" | cpio -idmv ;;
		*.deb)         ar -xv $1                  ;;
		*.pkg.tar.xz)  tar xvJf $1                ;;
		*)             echo "'$1' cannot be extracted via >extract<" ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

## Other

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable bash completions.
[ -r /usr/share/bash-completion/bash_completion   ] && \
	source /usr/share/bash-completion/bash_completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	source /etc/bash_completion
fi


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
unset source_dl
unset source_repo
unset bash_powerline_name
unset bash_powerline_dl
unset bash_powerline_repo
unset bash_powerline_path

unset _bashrc_deploy
unset _bashrc_deploy_plugins
unset _bashrc_install
unset _bashrc_uninstall
unset _bashrc_reloging_msg
unset _bashrc_help


### OVERIDES

# Store all kinds of useful specific overrides and fixes.
# Use/add/modify per machine whenever needed. Feel
# free to keep local override files in version control
# and/or backups.

# '|| true' is needed orotherwise the overall exit code of the sourcing is 1
[ -f ~/.bashrc_override ] && source ~/.bashrc_override || true

# Some useful overrides that I've picked up so far.

## Login

## MANUAL FIX FOR XUBUNTU/old XFCE (<4.11??) and RHEL (v6??).
# For some reason the xfce4-terminal in xubuntu
# cannot properly set the TERM var.
#export TERM=xterm-256color


## Env variables

# Some tools like to drop you to a terminal when encountering a problem.
#export OE_TERMINAL_CUSTOMCMD="gnome-terminal"


## Other

# Set the proper terminal tab title, even though PROMPT_COMMAND will point to a function.
# This fix is needed for some terminal emulators, that cannot handle the custom PROMPT_COMMAND.
# TERM_TITLE='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
# PROMPT_COMMAND="$PROMPT_COMMAND${PROMPT_COMMAND:+; $TERM_TITLE}"


## Unset

# unset TERM_TITLE

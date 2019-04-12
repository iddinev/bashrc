#
# ~/.bashrc
#

# Login

# If not running interactively, don't do anything.
[[ "$-" != *i* ]] && return


## Prompts/Colors

# Taken from Gentoo's default .bashrc
case "${TERM}" in
	[aEkx]term*|rxvt*|gnome*|konsole*|interix)
		PS1='\[\033]0;\u@\h:\W\007\]'
		;;
	screen*)
		PS1='\[\033k\u@\h:\W\033\\\]'
		;;
	*)
		unset PS1
		;;
esac

use_color=false
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
		use_color=true
	else
		# Delete it if it's empty as it's useless in that case.
		unset LS_COLORS
	fi
else
	# Some systems (e.g. BSD & embedded) don't typically come with
	# dircolors so we need to hardcode some terminals in here.
	case "${TERM}" in
	[aEkx]term*|rxvt*|gnome*|konsole*|screen|cons25|*color) use_color=true;;
	esac
fi

if "${use_color}" ; then
	if [[ "${EUID}" == 0 ]] ; then
		PS1+='\[\033[01;31m\][\h\[\033[01;34m\] \W]\$\[\033[00m\] '
	else
		PS1+='\[\033[01;32m\][\u@\h\[\033[01;34m\] \W]\$\[\033[00m\] '
	fi
else
	# show root@ when we don't have colors
	PS1+='[\u@\h \W]\$ '
fi



## Bash options

# Disable flow control (CTRL-S freezing io)
stty -ixon

# Append to the history file, don't overwrite it
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


## Other

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable bash completions.
[ -r /usr/share/bash-completion/bash_completion   ] && \
	source /usr/share/bash-completion/bash_completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	source /etc/bash_completion
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

# Manage dot files inside $HOME without messing up any other repo(s) inside $HOME.
alias git_rc='/usr/bin/git --git-dir=$HOME/.home_configs_git/ --work-tree=$HOME'

alias git_bash='/usr/bin/git --git-dir=$HOME/.bashrc_git/ --work-tree=$HOME'

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


## Unset

unset use_color

#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export HISTCONTROL=ignoreboth

# Disable flow control (CTRL-S freezing io)
stty -ixon


## Env variables

# Use vim if available.
if [ "$(which vim 2>/dev/null)" ]; then
	export VISUAL='vim'
	export EDITOR=$VISUAL
fi


## Aliases

# Manage dot files inside $HOME without messing up any other repos inside $HOME.
alias git_rc='/usr/bin/git --git-dir=$HOME/.home_configs/ --work-tree=$HOME'

#
# ~/.bashrc
#

# Login

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


## Prompts

PS1='[\u@\h \W]\$ '


## Bash options 

# Disable flow control (CTRL-S freezing io)
stty -ixon

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


## Env variables

export HISTCONTROL=ignoreboth

# Use vim if available.
if [ "$(which vim 2>/dev/null)" ]; then
	export VISUAL='vim'
	export EDITOR=$VISUAL
fi


## Aliases

alias ls='ls --color=auto'

# Manage dot files inside $HOME without messing up any other repo(s) inside $HOME.
alias git_rc='/usr/bin/git --git-dir=$HOME/.home_configs/ --work-tree=$HOME'

alias vim='vim -O'


## Functions

# Handy extract
function extract()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

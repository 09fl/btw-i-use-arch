
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s autocd cdspell dirspell globstar histappend
HISTCONTROL=ignoreboth:erasedups

export EDITOR='nano -/'
export VISUAL=$EDITOR
export LESS='-FMNR -x4 --mouse --wheel-lines=3 --use-color -DNy'

eval "$(dircolors)"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias sudo='sudo '
alias nano='nano -/'
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias l='ls -la'
alias grep='grep -Tn --color=auto'
alias man='MANWIDTH=$(($COLUMNS-7)) man'

if [ -f /usr/share/git/git-prompt.sh ]; then
    . /usr/share/git/git-prompt.sh
fi

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

# Style constants
RESET="\[$(tput sgr0)\]"
BOLD="\[$(tput bold)\]"
DIM="\[$(tput dim)\]"
ITALIC="\[$(tput sitm)\]"
UNDLINE="\[$(tput smul)\]"

BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 9)\]"
GREEN="\[$(tput setaf 10)\]"
YELLOW="\[$(tput setaf 11)\]"
BLUE="\[$(tput setaf 12)\]"
PURPLE="\[$(tput setaf 13)\]"
CYAN="\[$(tput setaf 14)\]"

PROMPT_COMMAND=__update_ps1
__update_ps1() {
    # Save last return value
    local retval="$?"
    PS1=""

    # 1st line
    # Add last return value
    if [ $retval -ne 0 ]; then
        PS1+="$BOLD$RED"
    else
        PS1+="$DIM$GREEN"
    fi
    PS1+="[$(printf %3d $retval)]$RESET "
    # Add username and hostname
    PS1+="$ITALIC$BLUE(\u@\h)$RESET "
    # Add current time
    local ps1_date=$(date '+%F %T.%3N')
    rand=$RANDOM
    for (( i=0; i<${#ps1_date}; i++ )); do
        color=$((202 + 6*($rand%4) + 6*$i/${#ps1_date}))
        PS1+="\[$(tput setaf $color)\]${ps1_date:$i:1}"
    done
    PS1+="$RESET "
    # Add current directory
    local ps1_pwd=$(dirs '+0')
    rand=$RANDOM
    PS1+="$BOLD"
    for (( i=0; i<${#ps1_pwd}; i++ )); do
        color=$((28 + 6*(${rand}%3) + 6*$i/${#ps1_pwd}))
        PS1+="\[$(tput setaf $color)\]${ps1_pwd:$i:1}"
    done
    PS1+="$RESET\n"

    # 2nd line
    # Add history number
    PS1+="$UNDLINE$CYAN#\!$RESET"
    # Add git info
    if [ "$(command -v __git_ps1)" ]; then PS1+="$(__git_ps1)"; fi
    # Add \$
    PS1+=' \$ '

    unset rand
    unset color
}

# pkgfile
if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
    source /usr/share/doc/pkgfile/command-not-found.bash
fi

# nvm
if [ -f /usr/share/nvm/init-nvm.sh ]; then
    source /usr/share/nvm/init-nvm.sh
fi

# rustup
if [ -d ~/.cargo/bin ]; then
    PATH="$PATH:~/.cargo/bin"
fi

if [ "$(command -v fastfetch)" ]; then
    if [ "$(command -v lolcat)" ]; then
        fastfetch | lolcat
    else
        fastfetch
    fi
fi

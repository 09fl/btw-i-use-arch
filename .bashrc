#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s autocd cdspell dirspell globstar histappend no_empty_cmd_completion
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

exists() {
    [[ -n $(command -v $1) ]]
}
src_if_exists() {
    if [[ -f $1 ]]; then source $1; fi
}
exe_if_exists() {
    if [[ -x $1 ]]; then $1; fi
}

src_if_exists /usr/share/git/git-prompt.sh

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
src_if_exists /usr/share/doc/pkgfile/command-not-found.bash

# nvm
src_if_exists /usr/share/nvm/init-nvm.sh

# rustup
if [[ -d ~/.cargo/bin ]]; then
    PATH="$PATH:~/.cargo/bin"
fi

# fastfetch
if shopt -q login_shell && exists fastfetch; then
    if exists lolcat; then
        fastfetch --logo ~/btw-i-use-arch/monika2.raw --logo-width 50 --logo-height 25 | lolcat
    else
        fastfetch --logo ~/btw-i-use-arch/monika.raw --logo-width 50 --logo-height 25
    fi
fi

# monika
monika() {
    local target=$(echo "aHR0cHM6Ly9pamsubW9lL2FwaS9jYXRncHQvc2ltcGxl" | base64 -d)
    local input=""
    while read -r; do
        input="$input$REPLY"
    done
    local output=$(curl -s -X POST -d "{\"message\":\"$input\"}" "$target")
    echo -e "$output"
}

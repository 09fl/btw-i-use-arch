#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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

# 256-color constants
R256="38;5;9"
G256="38;5;10"
Y256="38;5;11"
B256="38;5;12"
P256="38;5;13"
C256="38;5;14"

# Helpers
exists() {
    [[ -n $(command -v $1) ]]
}
src_if_exists() {
    if [[ -f $1 ]]; then source $1; fi
}
exe_if_exists() {
    if [[ -x $1 ]]; then $1; fi
}

# Bash configs
shopt -s autocd cdspell dirspell globstar histappend no_empty_cmd_completion
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=100000

# Aliases and colors
export EDITOR='nano -/'
export VISUAL=$EDITOR
export LESS='-FMNR -x4 --mouse --wheel-lines=3 --use-color -DNy'
if exists source-highlight; then
    export LESSOPEN="| source-highlight --infer-lang --failsafe --outlang-def=$HOME/btw-i-use-arch/esc256.outlang --style-file=esc256.style -i %s"
fi
export GREP_COLORS="mt=01;$R256:fn=$P256:ln=$Y256:bn=$Y256:se=$C256"
eval "$(dircolors ~/btw-i-use-arch/LS_COLORS)"

alias sudo='sudo '
alias nano='nano -/'
alias man='MANWIDTH=$(($COLUMNS-7)) man'
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias l='ls -la'
alias grep='grep -Tn --color'
alias diff="diff --color --palette=\"ad=$G256:de=$R256:ln=$C256\""

# Git promot
src_if_exists /usr/share/git/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

# Main prompt
PROMPT_COMMAND="__update_ps1; history -n; history -w; history -c; history -r"
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
    # Add virtualenv info
    if [[ -v VIRTUAL_ENV_PROMPT ]]; then PS1+=" ($YELLOW$VIRTUAL_ENV_PROMPT$RESET)"; fi
    # Add git info
    if exists __git_ps1; then PS1+="$(__git_ps1)"; fi
    # Add \$
    PS1+=' \$ '

    unset rand
    unset color
}

# pkgfile
src_if_exists /usr/share/doc/pkgfile/command-not-found.bash

# virtualenvwrapper
export WORKON_HOME=~/.virtualenvs
src_if_exists /usr/bin/virtualenvwrapper.sh

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

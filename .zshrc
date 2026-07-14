#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

# Helpers
SCRIPT_PATH=${(%):-%x}
SCRIPT_DIR=${SCRIPT_PATH:A:h}
exists() { [[ -n $(command -v $1) ]] }
src_if_exists() { [[ -f $1 ]] && source $1 }
exe_if_exists() { [[ -x $1 ]] && $1 }
eval "$(dircolors $SCRIPT_DIR/LS_COLORS)"

# Zsh configs
autoload -Uz compinit promptinit colors
compinit
promptinit
colors

setopt autocd notify completeinword listrowsfirst
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.histfile
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 3
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Style & color constants
RESET="%{$(tput sgr0)%}"
DIM="%{$(tput dim)%}"
ITALIC="%{$(tput sitm)%}"
R256="38;5;9"
G256="38;5;10"
Y256="38;5;11"
B256="38;5;12"
P256="38;5;13"
C256="38;5;14"

# Windows Terminal fix
if [[ -n $WT_SESSION ]]; then export COLORTERM='truecolor'; fi

# Aliases and colors
export EDITOR=nano
export VISUAL=$EDITOR
export LESS='-FMNR -x4 --mouse --wheel-lines=3 --use-color -DNy'
export LESSHISTFILE=-
if exists source-highlight; then
    export LESSOPEN="| source-highlight --infer-lang --failsafe --outlang-def=$SCRIPT_DIR/esc256.outlang --style-file=esc256.style -i %s"
fi
export GREP_COLORS="mt=01;${R256}:fn=${P256}:ln=${Y256}:bn=${Y256}:se=${C256}"

alias sudo='sudo '
alias man='MANWIDTH=$(($COLUMNS-7)) man'
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias l='ls -la'
alias grep='grep -Tn --color'
alias diff="diff -u --color --palette=\"ad=${G256}:de=${R256}:ln=${C256}\""

# Git prompt
src_if_exists /usr/share/git/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

setopt prompt_subst
precmd() {
    # Save last return value
    local retval=$?
    PROMPT=""

    # 1st line
    # Add last return value
    if [ $retval -ne 0 ]; then
        PROMPT+="%B%F{9}"
    else
        PROMPT+="$DIM%F{10}"
    fi
    PROMPT+="[$(printf %3d $retval)]%f%b$RESET "
    # Add username and hostname
    PROMPT+="$ITALIC%F{12}(%n@%m)%f$RESET "
    # Add current time
    local ps1_date=$(date '+%F %T.%3N')
    local rand=$RANDOM
    local i
    for (( i=0; i<${#ps1_date}; i++ )); do
        local color=$((202 + 6*(rand%4) + 6*i/${#ps1_date}))
        PROMPT+="%F{$color}${ps1_date:$i:1}"
    done
    PROMPT+="%f "
    # Add current directory
    local ps1_pwd=$(print -P "%~")
    rand=$RANDOM
    PROMPT+="%B"
    for (( i=0; i<${#ps1_pwd}; i++ )); do
        local color=$((28 + 6*(rand%3) + 6*i/${#ps1_pwd}))
        PROMPT+="%F{$color}${ps1_pwd:$i:1}"
    done
    PROMPT+="%f%b"
    PROMPT+=$'\n'

    # 2nd line
    # Add history number
    PROMPT+="%U%F{14}#%h%f%u"
    # Add virtualenv info
    if [[ -v VIRTUAL_ENV_PROMPT ]]; then
        PROMPT+=" ("
        if [[ $VIRTUAL_ENV_PROMPT = $(basename $PWD) ]]; then
            PROMPT+="%F{11}"
        else
            PROMPT+="%F{9}"
        fi
        PROMPT+="$VIRTUAL_ENV_PROMPT%f)"
    fi
    # Add git info
    if exists __git_ps1; then
        PROMPT+="$(__git_ps1)"
    fi
    PROMPT+=' %# '
}

# pkgfile
src_if_exists /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
src_if_exists /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
src_if_exists /usr/share/doc/pkgfile/command-not-found.zsh

# nvm
src_if_exists /usr/share/nvm/init-nvm.sh

# uv & rustup
if [[ -d ~/.local/bin ]]; then export PATH="$HOME/.local/bin:$PATH"; fi
if [[ -d ~/.cargo/bin ]]; then export PATH="$HOME/.cargo/bin:$PATH"; fi

# fastfetch
if [[ -o login ]] && exists fastfetch; then
    if exists lolcat; then
        fastfetch --logo $SCRIPT_DIR/monika2.raw --logo-width 50 --logo-height 25 | lolcat
    else
        fastfetch --logo $SCRIPT_DIR/monika.raw --logo-width 50 --logo-height 25
    fi
fi

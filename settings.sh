# OVERALL CONDITIONALS {{{
_islinux=false
[[ "$(uname -s)" =~ Linux|GNU|GNU/* ]] && _islinux=true

_isarch=false
[[ -f /etc/arch-release ]] && _isarch=true

_isxrunning=false
[[ -n "$DISPLAY" ]] && _isxrunning=true

_isroot=false
[[ $UID -eq 0 ]] && _isroot=true
# }}}


# BASH OPTIONS {{{
shopt -s cdspell                 # Correct cd typos
shopt -s checkwinsize            # Update windows size on command
shopt -s histappend              # Append History instead of overwriting file
shopt -s cmdhist                 # Bash attempts to save all lines of a multiple-line command in the same history entry
shopt -s expand_aliases
shopt -s extglob                 # Extended pattern
shopt -s no_empty_cmd_completion # No empty completion
#}}}

# COMPLETION {{{
complete -cf sudo
if [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
fi
#}}}


# CONFIG {{{
export PATH=/usr/local/bin:$PATH
if [[ -d "$HOME/bin" ]] ; then
    PATH="$HOME/bin:$PATH"
fi

# NVM {{{
if [[ -f "/usr/share/nvm/nvm.sh" ]]; then
    source /usr/share/nvm/init-nvm.sh
fi
#}}}


# CHRUBY {{{
if [[ -f "/usr/share/chruby/chruby.sh" ]]; then
    source /usr/share/chruby/chruby.sh
fi
#}}}


# VTE {{{
if [[ -f "/etc/profile.d/vte.sh" ]]; then
    . /etc/profile.d/vte.sh
fi
#}}}


# ANDROID SDK {{{
if [[ -d "/opt/android-sdk" ]]; then
    export ANDROID_HOME=/opt/android-sdk
fi
#}}}


# EDITOR {{{
if which vim &>/dev/null; then
    export EDITOR="vim"
    elif which emacs &>/dev/null; then
    export EDITOR="emacs -nw"
else
    export EDITOR="nano"
fi
#}}}


# BASH HISTORY {{{
# make multiple shells share the same history file
export HISTSIZE=1000            # bash history will save N commands
export HISTFILESIZE=${HISTSIZE} # bash will remember N commands
export HISTCONTROL=ignoreboth   # ingore duplicates and spaces
export HISTIGNORE='&:ls:ll:la:cd:exit:clear:history'
#}}}


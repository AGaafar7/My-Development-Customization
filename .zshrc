# Homebrew setup
eval "$(/opt/homebrew/bin/brew shellenv)"

# Enable Git branch info (build-in Zsh)
autoload -Uz vcs_info
precmd() { vcs_info }

#Set Git display (Magenta branch name + cyan symbol)
zstyle ':vcs_info:git*' formats '%F{magenta}(%b)%f '
zstyle ':vcs_info:*' enable git

setopt prompt_subst
setopt transient_rprompt
setopt extended_history

# Customizing the look
# %n = username, %~ = current folder, %# = $ or # symbol
PROMPT='%F{cyan}%n%f in %F{yellow}%~%f ${vcs_info_msg_0_} '

# Optional : Right-side prompt for the time in light gray
RPROMPT='%F{242}%*%f '


# Local variable to save last buffer 
typeset -g _AS_LAST_BUFFER=""
typeset -g AS_HISTORY_LIMIT=500
typeset -g _AS_LAST_SUGGESTION=""

# Auto Suggest function
_autosuggest_compute() {
    [[ -z $BUFFER ]] && {
        POSTDISPLAY=""
        _AS_LAST_BUFFER=""
        _AS_LAST_SUGGESTION=""
        return
    }

    # If buffer unchanged, reuse cached suggestion
    if [[ $BUFFER == $_AS_LAST_BUFFER ]]; then
        POSTDISPLAY=$_AS_LAST_SUGGESTION
        return
    fi

    _AS_LAST_BUFFER=$BUFFER
    POSTDISPLAY=""
    _AS_LAST_SUGGESTION=""

    local cmd suggestion count=0

    for cmd in ${(On)history}; do
        (( ++count > AS_HISTORY_LIMIT )) && return
        [[ $cmd == ' '* ]] && continue
        [[ $cmd == "$BUFFER"* ]] || continue
        (( ${#cmd} <= ${#BUFFER} )) && continue

        suggestion=${cmd#$BUFFER}
        POSTDISPLAY=$suggestion
        _AS_LAST_SUGGESTION=$suggestion
        return
    done
}


_autosuggest_apply_style() {
    region_highlight=()
    [[ -n $POSTDISPLAY ]] && region_highlight=("P0 P${#POSTDISPLAY} fg=242")
}



# Function to accept suggestion with the right arrow key
_autosuggest_accept() {
    if [[ -n $POSTDISPLAY ]]; then
        BUFFER+=$POSTDISPLAY
        POSTDISPLAY=""
        region_highlight=()
        CURSOR=${#BUFFER}
    else
        zle forward-char
    fi
}

# Hook into every keystroke
self-insert() {
    zle .self-insert
    _autosuggest_compute
}

# Making the backspace key functionality 
backward-delete-char() {
    zle .backward-delete-char
    _autosuggest_compute
}

# Registering functions as widget
zle -N zle-line-pre-redraw _autosuggest_apply_style
zle -N self-insert
zle -N backward-delete-char
zle -N _autosuggest_accept

bindkey '^[[C' _autosuggest_accept

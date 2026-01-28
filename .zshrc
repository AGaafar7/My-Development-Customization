# Prompt
PROMPT='%F{green}%n%f in %F{cyan}%~%f '

# Local variable to save last buffer 
typeset -g _AS_LAST_BUFFER=""

# Auto Suggest function
_autosuggest_compute() {
    POSTDISPLAY=""
    region_highlight=()

    [[ -z $BUFFER ]] && return
    [[ $BUFFER == $_AS_LAST_BUFFER ]] && return

    _AS_LAST_BUFFER=$BUFFER

    local cmd suggestion count=0

    # Walk history newest → oldest
    for cmd in ${(On)history}; do
        (( ++count > AS_HISTORY_LIMIT )) && return

        # Ignore commands starting with space
        [[ $cmd == ' '* ]] && continue

        # Must start with current buffer
        [[ $cmd == "$BUFFER"* ]] || continue

        # Must be longer than what is typed
        (( ${#cmd} <= ${#BUFFER} )) && continue

        suggestion=${cmd#$BUFFER}
        POSTDISPLAY=$suggestion
        region_highlight=("P0 P${#suggestion} fg=242")
        return
    done
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
    POSTDISPLAY=""
    region_highlight=()
    zle .self-insert
    _autosuggest_compute
}

# Making the backspace key functionality 
backward-delete-char() {
    POSTDISPLAY=""
    region_highlight=()
    zle .backward-delete-char
    _autosuggest_compute
}

# Registering functions as widget
zle -N self-insert
zle -N backward-delete-char
zle -N _autosuggest_accept

bindkey '^[[C' _autosuggest_accept

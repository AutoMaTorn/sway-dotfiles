# Shared fuzzel dropdown: drops from the top centre, under the bar.
# usage: printf '...' | menu PROMPT [extra fuzzel args]
menu() {
    local prompt="$1"; shift
    fuzzel --dmenu --prompt "$prompt › " --anchor top --y-margin 54 \
        --width 38 --lines 12 "$@"
}

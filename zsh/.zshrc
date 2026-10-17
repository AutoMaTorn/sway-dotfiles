export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a"

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "[zsh] Oh My Zsh не найден. Запустите install.sh для установки."
fi

# Agnoster recoloured to greys: map its named colours onto grey shades.
if (( $+functions[prompt_segment] )); then
    functions[_ag_segment]=$functions[prompt_segment]
    prompt_segment() {
        local bg=$1 fg=$2; shift 2
        case $bg in
            blue)                        bg=240 fg=255 ;;
            green|yellow|red|magenta|cyan) bg=237 fg=252 ;;
            black)                       bg=234 fg=250 ;;
        esac
        _ag_segment "$bg" "$fg" "$@"
    }
fi

export PATH="$PATH:/sbin:/usr/sbin"

if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# nvm is slow to source (~0.5s): load it on first use of nvm/node/npm/npx
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    _nvm_lazy() {
        unset -f nvm node npm npx _nvm_lazy
        \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    for _c in nvm node npm npx; do
        eval "$_c() { _nvm_lazy; $_c \"\$@\"; }"
    done
    unset _c
fi

# kimi-code
[ -d "$HOME/.kimi-code/bin" ] && export PATH="$HOME/.kimi-code/bin:$PATH"

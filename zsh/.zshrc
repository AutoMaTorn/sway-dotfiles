export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions)
AGNOSTER_DIR_FG=white

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "[zsh] Oh My Zsh не найден. Запустите install.sh для установки."
fi

# Show system info only in interactive shells, if fastfetch is installed
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
    fastfetch
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
export PATH="/home/torn/.kimi-code/bin:$PATH"

# Oh My Zsh is not loaded: it cost ~150ms per shell for a prompt and one plugin.
HISTFILE=~/.zsh_history HISTSIZE=50000 SAVEHIST=50000
setopt hist_ignore_dups share_history auto_cd
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
zstyle ':completion:*' menu select
bindkey -e
bindkey '^[[3~' delete-char

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a"
for f in ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
         /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
    [[ -f $f ]] && { source $f; break; }
done

alias ls='ls --color=auto' ll='ls -lah --color=auto' gs='git status' ga='git add' gc='git commit' gp='git push'

# Prompt: white/grey only, readable on #181818
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{245}(%b)%f'
precmd() { vcs_info }
PROMPT='%F{250}%~%f${vcs_info_msg_0_} %B%F{255}❯%f%b '

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

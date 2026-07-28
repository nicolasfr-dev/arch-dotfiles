# Ferramentas de terminal - carregado no fim do ~/.bashrc
# Tudo aqui e guardado por `command -v`: se o binario nao existir, nada quebra.

# ---------- eza (ls moderno) ----------
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -l --group-directories-first --icons=auto --git --time-style=long-iso'
    alias la='eza -la --group-directories-first --icons=auto --git --time-style=long-iso'
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
    alias ltt='eza --tree --level=3 --group-directories-first --icons=auto'
fi

# ---------- bat (cat com syntax highlight) ----------
# Aliases nao valem em shell nao-interativo, entao scripts seguem usando o cat real.
if command -v bat >/dev/null; then
    export BAT_THEME="tokyonight_night"
    alias cat='bat --paging=never'
    alias catp='bat'                     # com paginacao
    # man colorido
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# ---------- fd ----------
command -v fd >/dev/null && alias find-fast='fd'

# ---------- ripgrep ----------
command -v rg >/dev/null && alias grepr='rg'

# ---------- zoxide (cd por frequencia) ----------
# `z <trecho>` pula pro diretorio mais usado que casa; `zi` abre no fzf.
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# ---------- fzf ----------
if command -v fzf >/dev/null; then
    # Tokyo Night
    export FZF_DEFAULT_OPTS="
      --height 45% --layout=reverse --border=rounded --info=inline
      --color=bg+:#292e42,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7
      --color=fg:#c0caf5,header:#7aa2f7,info:#7dcfff,pointer:#bb9af7
      --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7dcfff
      --color=border:#3b4261"

    if command -v fd >/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    command -v bat >/dev/null && \
        export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"

    # fzf >= 0.48 expoe o proprio setup; versoes antigas usam os arquivos do pacote
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        [[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
        [[ -f /usr/share/fzf/completion.bash   ]] && source /usr/share/fzf/completion.bash
    fi
fi

# ---------- git ----------
command -v lazygit >/dev/null && alias lg='lazygit'

# ---------- atalhos ----------
alias dev='cd ~/dev'
alias dots='cd ~/.dotfiles'

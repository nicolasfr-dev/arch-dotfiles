#!/usr/bin/env bash
# Cria os symlinks de ~/.config -> ~/.dotfiles/config
# Uso: ./install.sh [--dry-run]
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# diretorios de ~/.config gerenciados por este repo
APPS=(hypr waybar foot swaync wofi wlogout qt5ct qt6ct gtk-3.0 gtk-4.0 bat)

c_ok=$'\e[32m'; c_warn=$'\e[33m'; c_info=$'\e[34m'; c_off=$'\e[0m'
say()  { printf '%s%s%s\n' "$c_info" "$*" "$c_off"; }
ok()   { printf '  %s✓%s %s\n' "$c_ok" "$c_off" "$*"; }
warn() { printf '  %s!%s %s\n' "$c_warn" "$c_off" "$*"; }

link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    ok "$dst (ja linkado)"
    return
  fi
  if (( DRY_RUN )); then
    warn "linkaria $dst -> $src"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    warn "backup de $(basename "$dst") em $BACKUP/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}

say "==> Symlinks de configuracao"
for app in "${APPS[@]}"; do
  [[ -d "$DOTFILES/config/$app" ]] && link "$DOTFILES/config/$app" "$CONFIG/$app"
done

say "==> Arquivos do \$HOME"
for f in "$DOTFILES"/home/.*; do
  base="$(basename "$f")"
  [[ "$base" == "." || "$base" == ".." ]] && continue
  link "$f" "$HOME/$base"
done

say "==> Wallpaper"
WALLDIR="$HOME/.local/share/wallpapers"
FALLBACK="$WALLDIR/tokyonight.png"

# Wallpapers de terceiros nao ficam no repo (nao redistribuo arte que nao e
# minha), entao aqui a gente checa o que o hyprpaper.conf realmente pede e
# avisa se o arquivo nao existe nesta maquina.
WANTED="$(sed -n 's|^[[:space:]]*path[[:space:]]*=[[:space:]]*||p' \
          "$DOTFILES/config/hypr/hyprpaper.conf" 2>/dev/null | head -1)"
WANTED="${WANTED/#\~/$HOME}"

mkdir -p "$WALLDIR"
if [[ -n "$WANTED" && -f "$WANTED" ]]; then
  ok "$(basename "$WANTED")"
elif (( DRY_RUN )); then
  warn "geraria o fallback $FALLBACK"
else
  [[ -n "$WANTED" ]] && warn "$(basename "$WANTED") nao existe nesta maquina"
  if [[ -f "$FALLBACK" ]]; then
    ok "fallback ja presente: $(basename "$FALLBACK")"
  else
    python3 "$DOTFILES/scripts/gen-wallpaper.py" "$FALLBACK" 1920 1080 >/dev/null
    ok "fallback gerado: $(basename "$FALLBACK")"
  fi
  [[ -n "$WANTED" ]] && warn "copie o arquivo para $WALLDIR/ ou aponte o hyprpaper.conf para o fallback"
fi

say "==> Tema do Zen Browser"
# O perfil ativo vem do installs.ini (mais confiavel que o profiles.ini, que
# pode listar perfis orfaos). O nome do diretorio tem espacos e parenteses.
ZEN_ROOT="$CONFIG/zen"
ZEN_PROFILE=""
if [[ -f "$ZEN_ROOT/installs.ini" ]]; then
  ZEN_PROFILE="$(sed -n 's/^Default=//p' "$ZEN_ROOT/installs.ini" | head -1)"
fi
if [[ -z "$ZEN_PROFILE" && -f "$ZEN_ROOT/profiles.ini" ]]; then
  ZEN_PROFILE="$(awk -F= '/^Path=/{p=$2} /^Default=1/{print p; exit}' "$ZEN_ROOT/profiles.ini")"
fi

if [[ -n "$ZEN_PROFILE" && -d "$ZEN_ROOT/$ZEN_PROFILE" ]]; then
  ok "perfil: $ZEN_PROFILE"
  if (( DRY_RUN )); then
    warn "linkaria user.js, userChrome.css e userContent.css no perfil"
  else
    mkdir -p "$ZEN_ROOT/$ZEN_PROFILE/chrome"
    # Arquivo a arquivo, e nao o diretorio chrome/ inteiro: o Zen gera
    # zen-themes.css ali dentro e sobrescreve o que estiver no caminho.
    link "$DOTFILES/config/zen/user.js"                "$ZEN_ROOT/$ZEN_PROFILE/user.js"
    link "$DOTFILES/config/zen/chrome/userChrome.css"  "$ZEN_ROOT/$ZEN_PROFILE/chrome/userChrome.css"
    link "$DOTFILES/config/zen/chrome/userContent.css" "$ZEN_ROOT/$ZEN_PROFILE/chrome/userContent.css"
  fi
else
  warn "perfil do Zen nao encontrado em $ZEN_ROOT - pulando"
fi

say "==> Tema do bat"
# O bat nao enxerga temas de ~/.config/bat/themes ate reconstruir o cache.
# Sem isso ele avisa "Unknown theme 'tokyonight_night'" a cada chamada.
if command -v bat >/dev/null; then
  if (( DRY_RUN )); then
    warn "rodaria: bat cache --build"
  else
    bat cache --build >/dev/null 2>&1 && ok "cache do bat reconstruido" \
      || warn "falha ao reconstruir o cache do bat"
  fi
else
  warn "bat nao instalado - pulando"
fi

say "==> Tema GTK"
GTK_THEME_NAME="$(ls -1 /usr/share/themes ~/.themes 2>/dev/null \
  | grep -iE '^tokyo' | grep -viE 'light' | sort | head -1 || true)"
if [[ -n "$GTK_THEME_NAME" ]]; then
  if (( DRY_RUN )); then
    warn "aplicaria tema GTK: $GTK_THEME_NAME"
  else
    # gtk3/gtk4: sem aspas
    for ini in "$DOTFILES/config/gtk-3.0/settings.ini" "$DOTFILES/config/gtk-4.0/settings.ini"; do
      [[ -f "$ini" ]] && sed -i -E "s|^gtk-theme-name=.*$|gtk-theme-name=${GTK_THEME_NAME}|" "$ini"
    done
    # gtk2: com aspas
    [[ -f "$DOTFILES/home/.gtkrc-2.0" ]] && \
      sed -i -E "s|^gtk-theme-name=.*$|gtk-theme-name=\"${GTK_THEME_NAME}\"|" "$DOTFILES/home/.gtkrc-2.0"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    ok "tema GTK: $GTK_THEME_NAME"
  fi
else
  warn "nenhum tema Tokyo Night em /usr/share/themes - instale tokyonight-gtk-theme-git"
fi

say "==> Pronto"
echo "  Recarregue com: hyprctl reload"

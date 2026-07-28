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
APPS=(hypr waybar foot swaync wofi wlogout qt5ct qt6ct gtk-3.0 gtk-4.0)

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
WALL="$HOME/.local/share/wallpapers/tokyonight.png"
if [[ -f "$WALL" ]]; then
  ok "$WALL (ja existe)"
elif (( DRY_RUN )); then
  warn "geraria $WALL"
else
  mkdir -p "$(dirname "$WALL")"
  python3 "$DOTFILES/scripts/gen-wallpaper.py" "$WALL" 1920 1080 >/dev/null
  ok "$WALL gerado"
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

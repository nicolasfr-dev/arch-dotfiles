#!/usr/bin/env bash
# Liga/desliga o tema Tokyo Night do Zen Browser.
#
#   zen-theme.sh off     remove os symlinks e limpa os prefs que este repo define
#   zen-theme.sh on      reaplica (equivale ao passo "Tema do Zen" do install.sh)
#   zen-theme.sh status  mostra o que esta ativo
#
# O Zen PRECISA estar fechado: ele reescreve o prefs.js ao sair e desfaria a
# limpeza.
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/zen"

# prefs que o user.js deste repo escreve. browser.theme.toolbar-theme fica de
# fora de proposito: ja existia no perfil antes destes dotfiles.
PREFS=(
  "toolkit.legacyUserProfileCustomizations.stylesheets"
  "ui.systemUsesDarkTheme"
  "browser.theme.content-theme"
  "browser.display.background_color.dark"
  "zen.theme.accent-color"
  "zen.theme.border-radius"
)

profile_dir() {
  local p=""
  [[ -f "$ZEN_ROOT/installs.ini" ]] && p="$(sed -n 's/^Default=//p' "$ZEN_ROOT/installs.ini" | head -1)"
  [[ -z "$p" && -f "$ZEN_ROOT/profiles.ini" ]] && \
    p="$(awk -F= '/^Path=/{x=$2} /^Default=1/{print x; exit}' "$ZEN_ROOT/profiles.ini")"
  [[ -n "$p" ]] && printf '%s/%s' "$ZEN_ROOT" "$p"
}

zen_running() { pgrep -f 'zen-bin' >/dev/null 2>&1; }

P="$(profile_dir)"
[[ -z "$P" || ! -d "$P" ]] && { echo "perfil do Zen nao encontrado"; exit 1; }

case "${1:-status}" in
  off)
    zen_running && { echo "feche o Zen primeiro (ele reescreve o prefs.js ao sair)"; exit 1; }
    rm -f "$P/user.js" "$P/chrome/userChrome.css" "$P/chrome/userContent.css"
    if [[ -f "$P/prefs.js" ]]; then
      cp "$P/prefs.js" "$P/prefs.js.bak"
      for k in "${PREFS[@]}"; do
        sed -i "/^user_pref(\"${k//./\\.}\"/d" "$P/prefs.js"
      done
      echo "prefs limpos (backup em prefs.js.bak)"
    fi
    echo "tema DESLIGADO - o Zen volta ao padrao no proximo start"
    ;;
  on)
    zen_running && { echo "feche o Zen primeiro"; exit 1; }
    mkdir -p "$P/chrome"
    ln -sfn "$DOTFILES/config/zen/user.js"                "$P/user.js"
    ln -sfn "$DOTFILES/config/zen/chrome/userChrome.css"  "$P/chrome/userChrome.css"
    ln -sfn "$DOTFILES/config/zen/chrome/userContent.css" "$P/chrome/userContent.css"
    echo "tema LIGADO - reinicie o Zen"
    ;;
  status)
    echo "perfil: $(basename "$P")"
    for f in user.js chrome/userChrome.css chrome/userContent.css; do
      [[ -L "$P/$f" ]] && echo "  ligado   $f" || echo "  ausente  $f"
    done
    zen_running && echo "  (Zen esta RODANDO)" || echo "  (Zen fechado)"
    ;;
  *)
    echo "uso: $0 {on|off|status}"; exit 1 ;;
esac
